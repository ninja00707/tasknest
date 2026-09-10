from dataclasses import dataclass


@dataclass
class Swing:
    t: int
    idx: int
    price: float
    kind: str


def find_swings(candles: list[dict], k: int = 2) -> list[Swing]:
    swings: list[Swing] = []
    n = len(candles)
    for i in range(k, n - k):
        c = candles[i]
        is_high = True
        is_low = True
        for j in range(1, k + 1):
            if candles[i - j]["h"] > c["h"] or candles[i + j]["h"] >= c["h"]:
                is_high = False
            if candles[i - j]["l"] < c["l"] or candles[i + j]["l"] <= c["l"]:
                is_low = False
        if is_high:
            swings.append(Swing(candles[i]["t"], i, c["h"], "high"))
        elif is_low:
            swings.append(Swing(candles[i]["t"], i, c["l"], "low"))
    swings.sort(key=lambda s: s.idx)
    return swings


def analyze(candles: list[dict], k: int = 2) -> dict:
    closed = candles[:-1]
    swings = find_swings(closed, k)
    by_idx = {s.idx: s for s in swings}

    trend: str | None = None
    trend_since = 0
    sh: Swing | None = None
    sl_: Swing | None = None
    events: list[dict] = []

    for i, c in enumerate(closed):
        new_swing = by_idx.get(i - k)
        if new_swing:
            if new_swing.kind == "high":
                sh = new_swing
            else:
                sl_ = new_swing

        if sh is None or sl_ is None:
            continue

        close = c["c"]
        etype = None
        if close < sl_.price:
            if trend != "bearish":
                etype = "bearish_shift" if trend == "bullish" else "bearish_start"
                trend = "bearish"
                trend_since = int(c["t"])
            else:
                etype = "bos_bearish"
            level = sl_.price
        elif close > sh.price:
            if trend != "bullish":
                etype = "bullish_shift" if trend == "bearish" else "bullish_start"
                trend = "bullish"
                trend_since = int(c["t"])
            else:
                etype = "bos_bullish"
            level = sh.price

        if etype:
            prev = events[-1] if events else None
            if not (prev and prev["t"] == int(c["t"]) and prev["type"] == etype):
                events.append(
                    {"t": int(c["t"]), "type": etype, "level": round(level, 2), "price": round(close, 2)}
                )

    last_high = max((s for s in swings if s.kind == "high"), key=lambda s: s.idx, default=None)
    last_low = max((s for s in swings if s.kind == "low"), key=lambda s: s.idx, default=None)

    if trend == "bullish" and last_low:
        flip = last_low.price
    elif trend == "bearish" and last_high:
        flip = last_high.price
    else:
        flip = None

    recent_swings = [
        {"t": int(s.t), "price": round(s.price, 2), "kind": s.kind}
        for s in swings[-14:]
    ]

    return {
        "interval_candles": len(closed),
        "k": k,
        "bias": trend,
        "trend_since": trend_since,
        "flip_level": round(flip, 2) if flip else None,
        "last_swing_high": {"t": int(last_high.t), "price": round(last_high.price, 2)} if last_high else None,
        "last_swing_low": {"t": int(last_low.t), "price": round(last_low.price, 2)} if last_low else None,
        "events": events[-8:],
        "swings": recent_swings,
        "current_price": round(candles[-1]["c"], 2),
    }
