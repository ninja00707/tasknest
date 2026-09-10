import threading
import time
import uuid

import analyst
import structure as structure_mod
from market import Market, MarketError

_runs: dict[str, dict] = {}
_lock = threading.Lock()


class BacktestParams:
    def __init__(
        self,
        interval: str = "1h",
        lookback: int = 300,
        step: int = 6,
        initial_usdt: float = 10000.0,
        trade_usd: float = 500.0,
        sl_pct: float = 2.0,
        tp_pct: float = 4.0,
        min_confidence: int = 55,
        slice_candles: int = 14,
        mode: str = "ai",
    ):
        self.interval = interval
        self.lookback = max(60, min(1000, lookback))
        self.step = max(1, step)
        self.initial_usdt = initial_usdt
        self.trade_usd = trade_usd
        self.sl_pct = sl_pct
        self.tp_pct = tp_pct
        self.min_confidence = min_confidence
        self.slice_candles = slice_candles
        self.mode = "structure" if mode == "structure" else "ai"


def start(params: BacktestParams) -> str:
    run_id = uuid.uuid4().hex[:12]
    record = {
        "id": run_id,
        "params": vars(params),
        "status": "running",
        "progress": 0.0,
        "started_at": int(time.time() * 1000),
        "error": None,
    }
    with _lock:
        _runs[run_id] = record
    t = threading.Thread(target=_run, args=(run_id, params), daemon=True)
    t.start()
    return run_id


def get(run_id: str) -> dict | None:
    with _lock:
        return _runs.get(run_id)


def list_runs(limit: int = 20) -> list[dict]:
    with _lock:
        runs = sorted(_runs.values(), key=lambda r: r["started_at"], reverse=True)
    return [{k: v for k, v in r.items() if k != "result"} if r.get("status") == "running" else r for r in runs[:limit]]


def _run(run_id: str, p: BacktestParams) -> None:
    try:
        if p.mode == "structure":
            _run_structure(run_id, p)
        else:
            _run_ai(run_id, p)
    except Exception as e:
        with _lock:
            _runs[run_id].update({"status": "failed", "progress": 100.0, "error": str(e)})


def _finish(
    run_id: str,
    p: BacktestParams,
    usdt: float,
    btc: float,
    last_price: float,
    trades: list[dict],
    equity_curve: list[dict],
) -> None:
    final_equity = usdt + btc * last_price if btc > 0 else usdt
    sells = [t for t in trades if t["side"] == "sell"]
    wins = sum(1 for s in sells if s.get("pnl", 0) > 0)
    peak = p.initial_usdt
    max_dd = 0.0
    for pt in equity_curve:
        peak = max(peak, pt["e"])
        max_dd = max(max_dd, (peak - pt["e"]) / peak * 100)

    result = {
        "mode": p.mode,
        "initial_usdt": p.initial_usdt,
        "final_equity": round(final_equity, 2),
        "pnl": round(final_equity - p.initial_usdt, 2),
        "pnl_pct": round((final_equity / p.initial_usdt - 1) * 100, 2),
        "trades": len(trades),
        "wins": wins,
        "losses": len(sells) - wins,
        "win_rate": round(wins / len(sells) * 100, 1) if sells else 0.0,
        "max_drawdown_pct": round(max_dd, 2),
        "equity_curve": equity_curve,
        "trade_log": trades,
    }
    with _lock:
        _runs[run_id].update(
            {
                "status": "done",
                "progress": 100.0,
                "finished_at": int(time.time() * 1000),
                "result": result,
            }
        )


def _run_structure(run_id: str, p: BacktestParams) -> None:
    def progress(pct: float) -> None:
        with _lock:
            if run_id in _runs:
                _runs[run_id]["progress"] = round(min(99.0, pct), 1)

    market = Market("BTCUSDT")
    candles = market.klines(p.interval, p.lookback)
    if len(candles) < 30:
        raise MarketError("not enough history")

    k = 2
    usdt = p.initial_usdt
    btc = 0.0
    entry = sl = tp = None
    trades: list[dict] = []
    equity_curve: list[dict] = []
    last_event_t = 0

    total = max(1, (len(candles) - 25) // p.step)
    done = 0
    i = 25
    while i < len(candles) - 2:
        window = candles[i : min(i + p.step, len(candles) - 1)]
        st = structure_mod.analyze(candles[: i + 1], k)
        shifts = [
            e for e in st["events"] if e["t"] > last_event_t and e["type"].endswith("shift")
        ]

        if shifts:
            ev = shifts[-1]
            last_event_t = ev["t"]
            fill = candles[i + 1]["o"]
            if ev["type"] == "bearish_shift" and btc > 0:
                proceeds = btc * fill
                trades.append(
                    {
                        "t": int(candles[i + 1]["t"]),
                        "side": "sell",
                        "price": round(fill, 2),
                        "qty": round(btc, 8),
                        "usdt": round(proceeds, 2),
                        "reason": f"Bearish shift broke {ev['level']:.0f}",
                        "pnl": round((fill / entry - 1) * 100, 2),
                    }
                )
                usdt += proceeds
                btc = 0.0
                entry = sl = tp = None
            elif ev["type"] == "bullish_shift" and btc == 0 and usdt >= 10:
                spend = min(p.trade_usd, usdt)
                qty = spend / fill
                sl_new = ev["level"] * 0.9985
                risk = max(fill - sl_new, fill * 0.001)
                sh_price = (st.get("last_swing_high") or {}).get("price") or 0
                tp_new = sh_price if sh_price > fill + risk * 0.5 else fill + 2 * risk
                usdt -= spend
                btc = qty
                entry, sl, tp = fill, sl_new, tp_new
                trades.append(
                    {
                        "t": int(candles[i + 1]["t"]),
                        "side": "buy",
                        "price": round(fill, 2),
                        "qty": round(qty, 8),
                        "usdt": round(spend, 2),
                        "reason": f"Bullish shift broke {ev['level']:.0f}",
                    }
                )

        if btc > 0 and entry:
            scan = window[1:] if shifts else window
            for c in scan:
                if c["l"] <= sl:
                    proceeds = btc * sl
                    trades.append(
                        {
                            "t": int(c["t"]),
                            "side": "sell",
                            "price": round(sl, 2),
                            "qty": round(btc, 8),
                            "usdt": round(proceeds, 2),
                            "reason": "SL hit",
                            "pnl": round((sl / entry - 1) * 100, 2),
                        }
                    )
                    usdt += proceeds
                    btc = 0.0
                    entry = sl = tp = None
                    break
                if c["h"] >= tp:
                    proceeds = btc * tp
                    trades.append(
                        {
                            "t": int(c["t"]),
                            "side": "sell",
                            "price": round(tp, 2),
                            "qty": round(btc, 8),
                            "usdt": round(proceeds, 2),
                            "reason": "TP hit",
                            "pnl": round((tp / entry - 1) * 100, 2),
                        }
                    )
                    usdt += proceeds
                    btc = 0.0
                    entry = sl = tp = None
                    break

        mark = window[-1]["c"]
        equity_curve.append({"t": int(window[-1]["t"]), "e": round(usdt + btc * mark, 2)})
        done += 1
        progress(done / total * 100)
        i += p.step

    _finish(run_id, p, usdt, btc, candles[-1]["c"], trades, equity_curve)


def _run_ai(run_id: str, p: BacktestParams) -> None:
    def progress(pct: float) -> None:
        with _lock:
            if run_id in _runs:
                _runs[run_id]["progress"] = round(min(99.0, pct), 1)

    market = Market("BTCUSDT")
    candles = market.klines(p.interval, p.lookback)
    if len(candles) < 30:
        raise MarketError("not enough history")

    usdt = p.initial_usdt
    btc = 0.0
    entry = sl = tp = None
    trades: list[dict] = []
    equity_curve: list[dict] = []
    decisions = (len(candles) - 20) // p.step

    done = 0
    i = 20
    while i < len(candles) - 1:
        window = candles[i : min(i + p.step, len(candles) - 1)]
        price_now = window[0]["c"]

        if btc > 0 and entry:
            exit_price, reason = None, None
            for c in window:
                if sl and c["l"] <= sl:
                    exit_price, reason = sl, "SL hit"
                    break
                if tp and c["h"] >= tp:
                    exit_price, reason = tp, "TP hit"
                    break
            if exit_price is None:
                dec = analyst.analyze(candles[max(0, i - p.slice_candles) : i + 1], btc)
                done += 1
                if dec["action"] in ("sell", "buy") and dec["confidence"] >= p.min_confidence:
                    exit_price, reason = price_now, f"AI {dec['action']} ({dec['confidence']}%)"
            if exit_price is not None:
                usdt += btc * exit_price
                trades.append(
                    {
                        "t": int(window[0]["t"]),
                        "side": "sell",
                        "price": round(exit_price, 2),
                        "qty": round(btc, 8),
                        "usdt": round(btc * exit_price, 2),
                        "reason": reason,
                        "pnl": round((exit_price / entry - 1) * 100, 2),
                    }
                )
                btc = 0.0
                entry = sl = tp = None

        else:
            dec = analyst.analyze(candles[max(0, i - p.slice_candles) : i + 1], btc)
            done += 1
            if dec["action"] == "buy" and dec["confidence"] >= p.min_confidence and usdt >= 10:
                fill = candles[i + 1]["o"]
                spend = min(p.trade_usd, usdt)
                btc = spend / fill
                usdt -= spend
                entry = fill
                sl = fill * (1 - p.sl_pct / 100)
                tp = fill * (1 + p.tp_pct / 100)
                trades.append(
                    {
                        "t": int(candles[i + 1]["t"]),
                        "side": "buy",
                        "price": round(fill, 2),
                        "qty": round(btc, 8),
                        "usdt": round(spend, 2),
                        "reason": f"{dec['reason']} ({dec['confidence']}%)",
                    }
                )

        mark = window[-1]["c"]
        equity_curve.append({"t": int(window[-1]["t"]), "e": round(usdt + btc * mark, 2)})
        progress(done / max(1, decisions) * 100)
        i += p.step

    _finish(run_id, p, usdt, btc, candles[-1]["c"], trades, equity_curve)
