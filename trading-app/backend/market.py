import requests

PRIMARY = "https://api.binance.com"
MIRROR = "https://data-api.binance.vision"


class MarketError(Exception):
    pass


class Market:
    def __init__(self, symbol: str = "BTCUSDT"):
        self.symbol = symbol
        self.base = PRIMARY

    def _get(self, path: str, params: dict) -> dict | list:
        for base in (self.base, MIRROR):
            try:
                resp = requests.get(f"{base}{path}", params=params, timeout=15)
                if resp.status_code in (451, 403, 418) and base == PRIMARY:
                    continue
                resp.raise_for_status()
                self.base = base
                return resp.json()
            except requests.RequestException as e:
                if base == MIRROR:
                    raise MarketError(f"Binance unreachable: {e}") from e
        raise MarketError("Binance unreachable")

    def klines(self, interval: str = "1h", limit: int = 200) -> list[dict]:
        raw = self._get("/api/v3/klines", {"symbol": self.symbol, "interval": interval, "limit": limit})
        return [
            {
                "t": int(k[0]),
                "o": float(k[1]),
                "h": float(k[2]),
                "l": float(k[3]),
                "c": float(k[4]),
                "v": float(k[5]),
            }
            for k in raw
        ]

    def ticker(self) -> dict:
        data = self._get("/api/v3/ticker/24hr", {"symbol": self.symbol})
        return {
            "price": float(data["lastPrice"]),
            "change_pct": float(data["priceChangePercent"]),
            "high": float(data["highPrice"]),
            "low": float(data["lowPrice"]),
            "volume": float(data["quoteVolume"]),
        }
