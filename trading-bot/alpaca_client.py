import requests

import config


class AlpacaError(Exception):
    pass


def _headers() -> dict:
    return {
        "APCA-API-KEY-ID": config.ALPACA_KEY,
        "APCA-API-SECRET-KEY": config.ALPACA_SECRET,
    }


def get(url: str, params: dict | None = None) -> dict:
    resp = requests.get(url, headers=_headers(), params=params or {}, timeout=30)
    if not resp.ok:
        raise AlpacaError(f"GET {url} -> {resp.status_code}: {resp.text[:300]}")
    return resp.json()


def post(url: str, payload: dict) -> dict:
    resp = requests.post(url, headers=_headers(), json=payload, timeout=30)
    if not resp.ok:
        raise AlpacaError(f"POST {url} -> {resp.status_code}: {resp.text[:300]}")
    return resp.json()


def get_account() -> dict:
    return get(f"{config.ALPACA_BASE_URL}/v2/account")


def is_market_open() -> bool:
    clock = get(f"{config.ALPACA_BASE_URL}/v2/clock")
    return bool(clock.get("is_open"))


def get_bars(symbol: str, limit: int = 15) -> list[dict]:
    data = get(
        f"{config.ALPACA_DATA_URL}/stocks/{symbol}/bars",
        params={"timeframe": "1Day", "limit": limit, "feed": "iex"},
    )
    bars = data.get("bars", [])
    if not bars:
        raise AlpacaError(f"No bar data returned for {symbol}")
    return [
        {
            "t": b["t"],
            "o": float(b["o"]),
            "h": float(b["h"]),
            "l": float(b["l"]),
            "c": float(b["c"]),
            "v": int(b["v"]),
        }
        for b in bars
    ]


def get_position_qty(symbol: str) -> int:
    try:
        pos = get(f"{config.ALPACA_BASE_URL}/v2/positions/{symbol}")
        return int(float(pos["qty"]))
    except AlpacaError as e:
        if "404" in str(e):
            return 0
        raise


def submit_market_order(symbol: str, side: str, qty: int) -> dict:
    order = post(
        f"{config.ALPACA_BASE_URL}/v2/orders",
        {
            "symbol": symbol,
            "qty": qty,
            "side": side,
            "type": "market",
            "time_in_force": "day",
        },
    )
    return {"id": order.get("id"), "status": order.get("status")}
