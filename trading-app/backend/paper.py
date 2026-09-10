import json
import os
import sqlite3
import threading
import time

DB_PATH = os.path.join(os.path.dirname(__file__), "paper_wallet.db")
INITIAL_USDT = 10000.0

_lock = threading.Lock()
_conn: sqlite3.Connection | None = None


def _db() -> sqlite3.Connection:
    global _conn
    if _conn is None:
        _conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        _conn.row_factory = sqlite3.Row
        _conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS state (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS trades (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts INTEGER NOT NULL,
                side TEXT NOT NULL,
                price REAL NOT NULL,
                qty REAL NOT NULL,
                usdt REAL NOT NULL,
                reason TEXT DEFAULT ''
            );
            CREATE TABLE IF NOT EXISTS decisions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts INTEGER NOT NULL,
                price REAL NOT NULL,
                action TEXT NOT NULL,
                confidence INTEGER NOT NULL,
                reason TEXT DEFAULT '',
                executed INTEGER NOT NULL DEFAULT 0
            );
            """
        )
        _conn.commit()
    return _conn


def _init_state() -> None:
    db = _db()
    row = db.execute("SELECT value FROM state WHERE key='usdt'").fetchone()
    if row is None:
        db.executemany(
            "INSERT INTO state(key, value) VALUES(?, ?)",
            [
                ("usdt", str(INITIAL_USDT)),
                ("btc", "0.0"),
                ("entry_price", ""),
                ("sl_price", ""),
                ("tp_price", ""),
                ("started_at", str(int(time.time() * 1000))),
            ],
        )
        db.commit()


_init_state()


def _set_state(db: sqlite3.Connection, key: str, value: str) -> None:
    db.execute(
        "INSERT INTO state(key, value) VALUES(?, ?) "
        "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
        (key, value),
    )


def reset() -> None:
    with _lock:
        db = _db()
        db.execute("DELETE FROM trades")
        db.execute("DELETE FROM decisions")
        for k in ("entry_price", "sl_price", "tp_price"):
            _set_state(db, k, "")
        _set_state(db, "usdt", str(INITIAL_USDT))
        _set_state(db, "btc", "0.0")
        _set_state(db, "started_at", str(int(time.time() * 1000)))
        db.commit()


def balances() -> tuple[float, float]:
    with _lock:
        db = _db()
        rows = {r["key"]: float(r["value"]) for r in db.execute("SELECT key, value FROM state") if r["value"] != ""}
    return rows.get("usdt", 0.0), rows.get("btc", 0.0)


def position() -> dict | None:
    with _lock:
        rows = {r["key"]: r["value"] for r in _db().execute("SELECT key, value FROM state")}
    if not rows.get("entry_price"):
        return None
    return {
        "entry": float(rows["entry_price"]),
        "sl": float(rows["sl_price"]) if rows.get("sl_price") else None,
        "tp": float(rows["tp_price"]) if rows.get("tp_price") else None,
    }


def set_position(entry: float | None, sl: float | None, tp: float | None) -> None:
    with _lock:
        db = _db()
        _set_state(db, "entry_price", repr(entry) if entry else "")
        _set_state(db, "sl_price", repr(sl) if sl else "")
        _set_state(db, "tp_price", repr(tp) if tp else "")
        db.commit()


def buy(usdt_amount: float, price: float, reason: str = "") -> dict | None:
    return buy_with_position(usdt_amount, price, reason, None, None)


def buy_with_position(
    usdt_amount: float, price: float, reason: str = "", sl: float | None = None, tp: float | None = None
) -> dict | None:
    with _lock:
        db = _db()
        usdt, btc = _balances(db)
        amount = min(usdt_amount, usdt)
        if amount < 10 or price <= 0:
            return None
        qty = amount / price
        _set_state(db, "usdt", repr(usdt - amount))
        _set_state(db, "btc", repr(btc + qty))
        _set_state(db, "entry_price", repr(price))
        _set_state(db, "sl_price", repr(sl) if sl else "")
        _set_state(db, "tp_price", repr(tp) if tp else "")
        cur = db.execute(
            "INSERT INTO trades(ts, side, price, qty, usdt, reason) VALUES(?,?,?,?,?,?)",
            (int(time.time() * 1000), "buy", price, qty, amount, reason),
        )
        db.commit()
        return {"id": cur.lastrowid, "side": "buy", "qty": qty, "usdt": amount}


def sell(price: float, reason: str = "", fraction: float = 1.0) -> dict | None:
    with _lock:
        db = _db()
        _, btc = _balances(db)
        qty = btc * max(0.0, min(1.0, fraction))
        if qty <= 0 or price <= 0:
            return None
        proceeds = qty * price
        _set_state(db, "btc", repr(btc - qty))
        usdt, _ = _balances(db)
        _set_state(db, "usdt", repr(usdt + proceeds))
        for k in ("entry_price", "sl_price", "tp_price"):
            _set_state(db, k, "")
        cur = db.execute(
            "INSERT INTO trades(ts, side, price, qty, usdt, reason) VALUES(?,?,?,?,?,?)",
            (int(time.time() * 1000), "sell", price, qty, proceeds, reason),
        )
        db.commit()
        return {"id": cur.lastrowid, "side": "sell", "qty": qty, "usdt": proceeds}


def _balances(db: sqlite3.Connection) -> tuple[float, float]:
    rows = {r["key"]: float(r["value"]) for r in db.execute("SELECT key, value FROM state")}
    return rows.get("usdt", 0.0), rows.get("btc", 0.0)


def wallet(price: float) -> dict:
    usdt, btc = balances()
    equity = usdt + btc * price
    pos = position()
    out = {
        "usdt": round(usdt, 2),
        "btc": round(btc, 8),
        "equity_usd": round(equity, 2),
        "pnl_usd": round(equity - INITIAL_USDT, 2),
        "pnl_pct": round((equity / INITIAL_USDT - 1) * 100, 2),
        "position": None,
    }
    if pos and btc > 0:
        entry = pos["entry"]
        out["position"] = {
            "entry": round(entry, 2),
            "sl": round(pos["sl"], 2) if pos["sl"] else None,
            "tp": round(pos["tp"], 2) if pos["tp"] else None,
            "qty": round(btc, 6),
            "upl": round((price - entry) * btc, 2),
            "upl_pct": round((price / entry - 1) * 100, 2),
        }
    return out


def record_decision(price: float, decision: dict, executed: bool) -> None:
    with _lock:
        db = _db()
        db.execute(
            "INSERT INTO decisions(ts, price, action, confidence, reason, executed) VALUES(?,?,?,?,?,?)",
            (
                int(time.time() * 1000),
                price,
                decision.get("action", "hold"),
                int(decision.get("confidence", 0)),
                decision.get("reason", ""),
                1 if executed else 0,
            ),
        )
        db.commit()


def trades(limit: int = 100) -> list[dict]:
    with _lock:
        rows = _db().execute(
            "SELECT ts, side, price, qty, usdt, reason FROM trades ORDER BY ts DESC LIMIT ?", (limit,)
        ).fetchall()
    return [dict(r) for r in rows]


def decisions(limit: int = 50) -> list[dict]:
    with _lock:
        rows = _db().execute(
            "SELECT ts, price, action, confidence, reason, executed FROM decisions ORDER BY ts DESC LIMIT ?",
            (limit,),
        ).fetchall()
    return [dict(r) for r in rows]


def export_state() -> str:
    with _lock:
        db = _db()
        payload = {
            "state": {r["key"]: r["value"] for r in db.execute("SELECT key, value FROM state")},
            "trades": [dict(r) for r in db.execute("SELECT * FROM trades")],
        }
    return json.dumps(payload)
