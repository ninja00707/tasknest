import os
from dotenv import load_dotenv

load_dotenv()

ALPACA_KEY = os.getenv("ALPACA_API_KEY", "")
ALPACA_SECRET = os.getenv("ALPACA_API_SECRET", "")
ALPACA_BASE_URL = os.getenv("ALPACA_BASE_URL", "https://paper-api.alpaca.markets")
ALPACA_DATA_URL = "https://data.alpaca.markets/v2"

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.1:8b")

WATCHLIST = [s.strip().upper() for s in os.getenv("WATCHLIST", "AAPL,MSFT,NVDA").split(",") if s.strip()]

DRY_RUN = os.getenv("DRY_RUN", "true").lower() == "true"
MAX_TRADE_USD = float(os.getenv("MAX_TRADE_USD", "500"))
LOOP_SECONDS = int(os.getenv("LOOP_SECONDS", "300"))


def validate() -> list[str]:
    errors = []
    if not ALPACA_KEY:
        errors.append("ALPACA_API_KEY missing (get free keys at https://alpaca.markets)")
    if not ALPACA_SECRET:
        errors.append("ALPACA_API_SECRET missing")
    return errors
