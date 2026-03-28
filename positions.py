"""
Position manager for simulated (dry-run) trading.
Tracks open positions, calculates P&L, enforces stop-loss / take-profit.
"""

import logging
import time
import uuid
from typing import Any, Dict, List, Optional

logger = logging.getLogger("finai.positions")


class PositionManager:
    def __init__(self):
        self.positions: List[Dict[str, Any]] = []
        self.trade_log: List[Dict[str, Any]] = []
        self.equity: float = 1000.0
        self.initial_equity: float = 1000.0

    def open_position(
        self,
        coin: str,
        action: str,
        price: float,
        size_usd: float,
        leverage: int,
        stop_loss_pct: float,
        take_profit_pct: float,
    ) -> Optional[Dict[str, Any]]:
        """Open a new simulated position."""
        quantity = (size_usd * leverage) / price if price > 0 else 0
        if quantity <= 0:
            return None

        # Determine direction for SL/TP
        is_long = "long" in action.lower()
        if is_long:
            stop_loss = price * (1 - stop_loss_pct)
            take_profit = price * (1 + take_profit_pct)
        else:
            stop_loss = price * (1 + stop_loss_pct)
            take_profit = price * (1 - take_profit_pct)

        position = {
            "id": str(uuid.uuid4())[:8],
            "coin": coin,
            "action": action,
            "entry_price": price,
            "current_price": price,
            "quantity": round(quantity, 6),
            "size_usd": size_usd,
            "leverage": leverage,
            "is_long": is_long,
            "stop_loss": round(stop_loss, 6),
            "take_profit": round(take_profit, 6),
            "pnl": 0.0,
            "pnl_pct": 0.0,
            "opened_at": time.time(),
        }

        self.positions.append(position)

        self.trade_log.append({
            "type": "open",
            "coin": coin,
            "action": action,
            "price": price,
            "size_usd": size_usd,
            "timestamp": time.time() * 1000,
        })

        logger.info(f"Opened {action} position on {coin} @ ${price:.2f}")
        return position

    def close_position(self, position_id: str, reason: str = "manual") -> Optional[Dict[str, Any]]:
        """Close a position by ID."""
        pos = None
        for p in self.positions:
            if p["id"] == position_id:
                pos = p
                break

        if not pos:
            return None

        self.positions.remove(pos)
        pnl = pos.get("pnl", 0.0)
        self.equity += pnl

        self.trade_log.append({
            "type": "close",
            "coin": pos["coin"],
            "action": pos["action"],
            "price": pos["current_price"],
            "pnl": pnl,
            "reason": reason,
            "timestamp": time.time() * 1000,
        })

        logger.info(f"Closed {pos['coin']} position ({reason}): P&L ${pnl:.4f}")
        return pos

    def update_prices(self, prices: Dict[str, float]):
        """Update current prices and P&L for all open positions."""
        to_close: List[tuple] = []

        for pos in self.positions:
            coin = pos["coin"]
            if coin in prices:
                current_price = prices[coin]
                pos["current_price"] = current_price
                entry = pos["entry_price"]

                if pos["is_long"]:
                    pnl_pct = (current_price - entry) / entry if entry > 0 else 0
                else:
                    pnl_pct = (entry - current_price) / entry if entry > 0 else 0

                pos["pnl_pct"] = round(pnl_pct * 100, 4)
                pos["pnl"] = round(pnl_pct * pos["size_usd"] * pos["leverage"], 4)

                # Check stop-loss / take-profit
                if pos["is_long"]:
                    if current_price <= pos["stop_loss"]:
                        to_close.append((pos["id"], "stop_loss"))
                    elif current_price >= pos["take_profit"]:
                        to_close.append((pos["id"], "take_profit"))
                else:
                    if current_price >= pos["stop_loss"]:
                        to_close.append((pos["id"], "stop_loss"))
                    elif current_price <= pos["take_profit"]:
                        to_close.append((pos["id"], "take_profit"))

        for pid, reason in to_close:
            self.close_position(pid, reason)

    @property
    def total_pnl(self) -> float:
        """Total unrealized P&L across all open positions."""
        return sum(p.get("pnl", 0.0) for p in self.positions)

    @property
    def current_equity(self) -> float:
        """Current equity including unrealized P&L."""
        return self.equity + self.total_pnl

    def get_state(self) -> Dict[str, Any]:
        """Return serializable state for the frontend."""
        return {
            "positions": self.positions,
            "trade_log": self.trade_log[-50:],  # Last 50 entries
            "equity": round(self.current_equity, 4),
            "total_pnl": round(self.equity - self.initial_equity + self.total_pnl, 4),
        }
