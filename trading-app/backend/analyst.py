import json
from datetime import datetime, timezone

import requests

OLLAMA_URL = "http://localhost:11434"
MODEL = "llama3.1:8b"

SYSTEM_PROMPT = (
    "You are an active crypto trading assistant managing a BTC/USDT spot position with paper money. "
    "You receive hourly OHLCV candles plus pre-computed indicators. Respond ONLY with JSON: "
    '{"action": "buy" | "sell" | "hold", "confidence": 0-100, "reason": "<max 20 words>"}. '
    "Guidance: long-only spot. When price is above both SMAs and momentum is positive, lean BUY. "
    "When price breaks below SMA7 with negative momentum while holding BTC, lean SELL. "
    "Use HOLD only for genuinely flat markets. Confidence must reflect conviction: "
    "aligned trend+momentum = 70-90, mixed = 40-60. Never output the same confidence for every case."
)


def _indicators(candles: list[dict]) -> dict:
    closes = [c["c"] for c in candles]
    n = len(closes)
    sma7 = sum(closes[-7:]) / min(7, n)
    sma24 = sum(closes[-min(24, n):]) / min(24, n)
    change_pct = (closes[-1] / closes[0] - 1) * 100 if closes[0] else 0.0
    hi = max(c["h"] for c in candles)
    lo = min(c["l"] for c in candles)
    return {
        "sma7": round(sma7, 1),
        "sma24": round(sma24, 1),
        "window_change_pct": round(change_pct, 2),
        "high": round(hi, 1),
        "low": round(lo, 1),
    }


def analyze(candles: list[dict], btc_balance: float) -> dict:
    ind = _indicators(candles)
    lines = [
        f"Pair: BTC/USDT",
        f"Held BTC: {btc_balance:.6f}",
        f"Price now: {candles[-1]['c']:.1f}",
        f"SMA7: {ind['sma7']} | SMA24: {ind['sma24']}",
        f"Window change: {ind['window_change_pct']}%",
        f"Window high/low: {ind['high']} / {ind['low']}",
        "",
    ]
    for c in candles:
        t = datetime.fromtimestamp(c["t"] / 1000, tz=timezone.utc).strftime("%m-%d %H:%M")
        lines.append(f"{t} O={c['o']:.0f} H={c['h']:.0f} L={c['l']:.0f} C={c['c']:.0f} V={c['v']:.1f}")
    resp = requests.post(
        f"{OLLAMA_URL}/api/chat",
        json={
            "model": MODEL,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": "\n".join(lines)},
            ],
            "stream": False,
            "format": "json",
            "options": {"temperature": 0.2},
        },
        timeout=120,
    )
    resp.raise_for_status()
    content = resp.json()["message"]["content"]
    try:
        raw = json.loads(content)
    except json.JSONDecodeError as e:
        raise ValueError(f"invalid model JSON: {content!r}") from e

    action = str(raw.get("action", "hold")).lower()
    if action not in ("buy", "sell", "hold"):
        action = "hold"
    try:
        confidence = max(0, min(100, int(raw.get("confidence", 0))))
    except (TypeError, ValueError):
        confidence = 0
    return {
        "action": action,
        "confidence": confidence,
        "reason": str(raw.get("reason", ""))[:200],
    }
