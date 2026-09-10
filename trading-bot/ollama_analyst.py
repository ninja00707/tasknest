import json

import requests

import config


class AnalystError(Exception):
    pass


SYSTEM_PROMPT = (
    "You are a cautious trading assistant. You receive recent daily OHLCV bars for one stock. "
    "Respond ONLY with a JSON object: "
    '{"action": "buy" | "sell" | "hold", "confidence": 0-100, "reason": "<max 20 words>"}. '
    "Rules: only suggest buy/sell when the trend is clear; prefer hold; never invent data."
)


def _build_user_prompt(symbol: str, bars: list[dict], position_qty: int) -> str:
    lines = [f"Stock: {symbol}", f"Current position: {position_qty} shares"]
    for b in bars:
        lines.append(
            f"{b['t'][:10]} O={b['o']} H={b['h']} L={b['l']} C={b['c']} V={b['v']}"
        )
    return "\n".join(lines)


def analyze(symbol: str, bars: list[dict], position_qty: int = 0) -> dict:
    resp = requests.post(
        f"{config.OLLAMA_URL}/api/chat",
        json={
            "model": config.OLLAMA_MODEL,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": _build_user_prompt(symbol, bars, position_qty)},
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
        decision = json.loads(content)
    except json.JSONDecodeError as e:
        raise AnalystError(f"Model returned invalid JSON: {content!r}") from e

    action = str(decision.get("action", "hold")).lower()
    if action not in ("buy", "sell", "hold"):
        action = "hold"
    try:
        confidence = max(0, min(100, int(decision.get("confidence", 0))))
    except (TypeError, ValueError):
        confidence = 0
    return {
        "action": action,
        "confidence": confidence,
        "reason": str(decision.get("reason", ""))[:200],
    }
