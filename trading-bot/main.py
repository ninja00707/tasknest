import argparse
import math
import time

import alpaca_client as alpaca
import config
from ollama_analyst import AnalystError, analyze


def log(msg: str) -> None:
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}")


def process_symbol(symbol: str, account: dict) -> None:
    bars = alpaca.get_bars(symbol)
    position_qty = alpaca.get_position_qty(symbol)
    last_close = bars[-1]["c"]

    try:
        decision = analyze(symbol, bars, position_qty)
    except AnalystError as e:
        log(f"{symbol}: analyst error -> {e}")
        return

    log(
        f"{symbol}: close=${last_close:.2f} pos={position_qty} "
        f"-> {decision['action'].upper()} ({decision['confidence']}%) | {decision['reason']}"
    )

    side = decision["action"]
    if side == "hold" or decision["confidence"] < 50:
        return

    if side == "buy":
        budget = min(config.MAX_TRADE_USD, float(account.get("buying_power", 0)))
        qty = math.floor(budget / last_close)
        if qty < 1:
            log(f"{symbol}: skipped buy, insufficient buying power")
            return
    else:
        qty = position_qty
        if qty < 1:
            log(f"{symbol}: skipped sell, no position")
            return

    if config.DRY_RUN:
        log(f"{symbol}: [DRY RUN] would {side} {qty} share(s)")
        return

    if not alpaca.is_market_open():
        log(f"{symbol}: market closed, skipping {side}")
        return

    result = alpaca.submit_market_order(symbol, side, qty)
    log(f"{symbol}: submitted {side} x{qty} -> order {result['id']} ({result['status']})")


def run_cycle() -> None:
    account = alpaca.get_account()
    log(
        f"account: ${float(account['equity']):,.2f} equity, "
        f"${float(account['buying_power']):,.2f} buying power"
    )
    for symbol in config.WATCHLIST:
        try:
            process_symbol(symbol, account)
        except (alpaca.AlpacaError, AnalystError) as e:
            log(f"{symbol}: ERROR {e}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Ollama + Alpaca paper trading bot")
    parser.add_argument("--once", action="store_true", help="run one cycle and exit")
    args = parser.parse_args()

    errors = config.validate()
    if errors:
        raise SystemExit("Config error:\n  " + "\n  ".join(errors))

    mode = "DRY RUN" if config.DRY_RUN else "LIVE PAPER TRADING"
    log(f"starting ({mode}) model={config.OLLAMA_MODEL} watchlist={config.WATCHLIST}")

    while True:
        try:
            run_cycle()
        except alpaca.AlpacaError as e:
            log(f"cycle failed: {e}")
        if args.once:
            break
        time.sleep(config.LOOP_SECONDS)


if __name__ == "__main__":
    main()
