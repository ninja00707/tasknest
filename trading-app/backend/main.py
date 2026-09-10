import asyncio
import os

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import analyst
import backtest as bt_mod
import market as market_mod
import paper
import structure

MIN_CONFIDENCE = int(os.getenv("BOT_MIN_CONFIDENCE", "55"))
MAX_TRADE_USD = float(os.getenv("BOT_MAX_TRADE_USD", "500"))
SL_PCT = float(os.getenv("BOT_SL_PCT", "2"))
TP_PCT = float(os.getenv("BOT_TP_PCT", "4"))
CYCLE_SECONDS = int(os.getenv("BOT_CYCLE_SECONDS", "60"))
ANALYSIS_INTERVAL = os.getenv("BOT_INTERVAL", "1h")
ANALYSIS_CANDLES = int(os.getenv("BOT_CANDLES", "24"))

STRATEGY_MODE = os.getenv("BOT_STRATEGY", "structure")
STRUCTURE_TF = os.getenv("STRUCTURE_TF", "4h")
SWING_K = int(os.getenv("SWING_K", "2"))
last_struct_event_ts = 0

app = FastAPI(title="AI Paper Trading Bot")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

market = market_mod.Market("BTCUSDT")
bot_running = False
bot_task: asyncio.Task | None = None
last_error: str | None = None


class BotState(BaseModel):
    running: bool


async def bot_cycle() -> None:
    global last_error
    try:
        if STRATEGY_MODE == "structure":
            await structure_cycle()
        else:
            await ai_cycle()
        last_error = None
    except Exception as e:
        last_error = str(e)
        print(f"[bot] cycle error: {e}")


async def _check_stop_targets(price: float) -> bool:
    usdt, btc = await asyncio.to_thread(paper.balances)
    pos = await asyncio.to_thread(paper.position)
    if not (pos and btc > 0 and (pos["sl"] or pos["tp"])):
        return False
    if pos["sl"] and price <= pos["sl"]:
        await asyncio.to_thread(paper.sell, price, f"SL hit @ {price:.2f}")
        print(f"[bot] SL HIT - sold @ ${price:,.2f}")
        return True
    if pos["tp"] and price >= pos["tp"]:
        await asyncio.to_thread(paper.sell, price, f"TP hit @ {price:.2f}")
        print(f"[bot] TP HIT - sold @ ${price:,.2f}")
        return True
    return False


async def structure_cycle() -> None:
    global last_struct_event_ts
    candles = await asyncio.to_thread(market.klines, STRUCTURE_TF, 400)
    st = await asyncio.to_thread(structure.analyze, candles, SWING_K)
    price = st["current_price"]

    if await _check_stop_targets(price):
        return

    events = st["events"]
    latest = events[-1] if events else None

    if latest and int(latest["t"]) > last_struct_event_ts and latest["type"].endswith("shift"):
        last_struct_event_ts = int(latest["t"])
        usdt, btc = await asyncio.to_thread(paper.balances)
        if latest["type"] == "bullish_shift" and btc < 0.00001 and usdt >= 10:
            sl = latest["level"] * 0.9985
            risk = max(price - sl, price * 0.001)
            target = st.get("last_swing_high", {})
            tp_candidate = (target or {}).get("price") or 0
            tp = tp_candidate if tp_candidate > price + risk * 0.5 else price + 2 * risk
            spend = min(MAX_TRADE_USD, usdt)
            result = await asyncio.to_thread(
                paper.buy_with_position,
                spend,
                price,
                f"Bullish shift broke {latest['level']:.0f}",
                round(sl, 2),
                round(tp, 2),
            )
            if result:
                print(f"[bot] STRUCTURE LONG @ ${price:,.2f} | SL ${sl:,.2f} TP ${tp:,.2f} ({latest['type']})")
        elif latest["type"] == "bearish_shift" and btc > 0:
            await asyncio.to_thread(paper.sell, price, f"Bearish shift broke {latest['level']:.0f}")
            print(f"[bot] STRUCTURE EXIT - bearish shift @ ${price:,.2f}")
    else:
        bias = st["bias"]
        print(f"[bot] structure {bias or 'neutral'} holding | flip ${st['flip_level'] or 0:,.2f} | px ${price:,.2f}")


async def ai_cycle() -> None:
    candles = await asyncio.to_thread(market.klines, ANALYSIS_INTERVAL, ANALYSIS_CANDLES)
    price = candles[-1]["c"]
    usdt, btc = await asyncio.to_thread(paper.balances)

    if await _check_stop_targets(price):
        return

    decision = await asyncio.to_thread(analyst.analyze, candles, btc)
    executed = False
    if (
        decision["action"] == "buy"
        and decision["confidence"] >= MIN_CONFIDENCE
        and btc < 0.00001
        and usdt >= 10
    ):
        sl = price * (1 - SL_PCT / 100)
        tp = price * (1 + TP_PCT / 100)
        result = await asyncio.to_thread(
            paper.buy_with_position, min(MAX_TRADE_USD, usdt), price, decision["reason"], round(sl, 2), round(tp, 2)
        )
        executed = result is not None
    elif decision["action"] == "sell" and decision["confidence"] >= MIN_CONFIDENCE and btc > 0:
        result = await asyncio.to_thread(paper.sell, price, decision["reason"])
        executed = result is not None

    await asyncio.to_thread(paper.record_decision, price, decision, executed)


async def bot_loop() -> None:
    global bot_running
    print("[bot] loop started", flush=True)
    while bot_running:
        await bot_cycle()
        for _ in range(CYCLE_SECONDS):
            if not bot_running:
                return
            await asyncio.sleep(1)


@app.get("/api/ticker")
def ticker() -> dict:
    try:
        return market.ticker()
    except market_mod.MarketError as e:
        raise HTTPException(502, str(e))


@app.get("/api/candles")
def candles(interval: str = "15m", limit: int = 200) -> list[dict]:
    valid = ("1m", "5m", "15m", "30m", "1h", "4h", "1d")
    if interval not in valid:
        raise HTTPException(400, f"interval must be one of {valid}")
    limit = max(10, min(1000, limit))
    try:
        return market.klines(interval, limit)
    except market_mod.MarketError as e:
        raise HTTPException(502, str(e))


@app.get("/api/wallet")
def wallet() -> dict:
    try:
        price = market.ticker()["price"]
    except market_mod.MarketError:
        price = 0.0
    return paper.wallet(price)


@app.get("/api/trades")
def trades() -> list[dict]:
    return paper.trades()


@app.get("/api/decisions")
def decisions() -> list[dict]:
    return paper.decisions()


@app.get("/api/bot")
def status() -> dict:
    return {"running": bot_running, "error": last_error}


class ToggleRequest(BaseModel):
    running: bool


@app.post("/api/bot")
async def toggle(req: ToggleRequest) -> dict:
    global bot_running, bot_task
    if req.running and not bot_running:
        bot_running = True
        bot_task = asyncio.create_task(bot_loop())
    elif not req.running and bot_running:
        bot_running = False
        if bot_task:
            bot_task.cancel()
            bot_task = None
    return {"running": bot_running}


@app.post("/api/reset")
def reset() -> dict:
    paper.reset()
    return {"ok": True}


class BacktestRequest(BaseModel):
    interval: str = "1h"
    lookback: int = 300
    step: int = 6
    initial_usdt: float = 10000.0
    trade_usd: float = 500.0
    sl_pct: float = 2.0
    tp_pct: float = 4.0
    min_confidence: int = 55
    mode: str = "ai"


@app.post("/api/backtest")
def start_backtest(req: BacktestRequest) -> dict:
    valid = ("1m", "5m", "15m", "30m", "1h", "4h", "1d")
    if req.interval not in valid:
        raise HTTPException(400, f"interval must be one of {valid}")
    params = bt_mod.BacktestParams(
        interval=req.interval,
        lookback=req.lookback,
        step=req.step,
        initial_usdt=req.initial_usdt,
        trade_usd=req.trade_usd,
        sl_pct=req.sl_pct,
        tp_pct=req.tp_pct,
        min_confidence=req.min_confidence,
        mode="structure" if req.mode == "structure" else "ai",
    )
    run_id = bt_mod.start(params)
    return {"id": run_id}


@app.get("/api/backtest/{run_id}")
def backtest_status(run_id: str) -> dict:
    run = bt_mod.get(run_id)
    if not run:
        raise HTTPException(404, "run not found")
    return run


@app.get("/api/backtests")
def backtest_list() -> list[dict]:
    return bt_mod.list_runs()


@app.get("/api/structure")
def structure_state(interval: str | None = None, k: int | None = None) -> dict:
    tf = interval or STRUCTURE_TF
    valid = ("15m", "30m", "1h", "4h", "1d")
    if tf not in valid:
        raise HTTPException(400, f"interval must be one of {valid}")
    kk = max(2, min(5, k or SWING_K))
    candles = market.klines(tf, 400)
    return structure.analyze(candles, kk)


@app.get("/api/strategy")
def strategy_get() -> dict:
    return {"mode": STRATEGY_MODE, "timeframe": STRUCTURE_TF}


class StrategyRequest(BaseModel):
    mode: str
    timeframe: str | None = None


@app.post("/api/strategy")
async def strategy_set(req: StrategyRequest) -> dict:
    global STRATEGY_MODE, STRUCTURE_TF, last_struct_event_ts
    if req.mode not in ("ai", "structure"):
        raise HTTPException(400, "mode must be ai or structure")
    if req.timeframe:
        if req.timeframe not in ("15m", "30m", "1h", "4h", "1d"):
            raise HTTPException(400, "invalid timeframe")
        STRUCTURE_TF = req.timeframe
        last_struct_event_ts = 0
    STRATEGY_MODE = req.mode
    print(f"[bot] strategy -> {STRATEGY_MODE} ({STRUCTURE_TF})")
    return {"mode": STRATEGY_MODE, "timeframe": STRUCTURE_TF}


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8321)
