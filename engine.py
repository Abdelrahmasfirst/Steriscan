"""
Arbitrage detection engine.
Scans funding rates across exchanges to find:
  1. Extreme funding rates (single exchange) — short the expensive side
  2. Cross-exchange divergence — long cheap, short expensive
"""

import logging
from typing import Any, Dict, List

logger = logging.getLogger("finai.engine")


def detect_opportunities(
    funding_rates: Dict[str, Dict[str, float]],
    prices: Dict[str, float],
    config: Dict[str, Any],
) -> List[Dict[str, Any]]:
    """
    Analyze funding rates and return a list of opportunity dicts.
    Each opportunity has: coin, type, action, expected_profit_pct, price, size_usd, details
    """
    threshold = config.get("funding_threshold", 0.0005)
    position_size = config.get("position_size", 100)
    leverage = config.get("leverage", 5)
    opportunities: List[Dict[str, Any]] = []

    # Collect all coins across exchanges
    all_coins = set()
    for exchange_rates in funding_rates.values():
        all_coins.update(exchange_rates.keys())

    for coin in sorted(all_coins):
        price = prices.get(coin)
        if not price or price <= 0:
            continue

        # Gather rates per exchange for this coin
        coin_rates: Dict[str, float] = {}
        for exchange, rates in funding_rates.items():
            if coin in rates:
                coin_rates[exchange] = rates[coin]

        if not coin_rates:
            continue

        # --- Strategy 1: Extreme Funding Rate ---
        for exchange, rate in coin_rates.items():
            abs_rate = abs(rate)
            if abs_rate >= threshold:
                # High positive funding → longs pay shorts → short is profitable
                # High negative funding → shorts pay longs → long is profitable
                if rate > 0:
                    action = f"short_{exchange}"
                    expected_profit = abs_rate * leverage
                else:
                    action = f"long_{exchange}"
                    expected_profit = abs_rate * leverage

                opportunities.append({
                    "coin": coin,
                    "type": "extreme_funding",
                    "action": action,
                    "expected_profit_pct": expected_profit,
                    "price": price,
                    "size_usd": position_size,
                    "exchange": exchange,
                    "funding_rate": rate,
                    "details": f"{exchange} funding: {rate*100:.4f}%",
                })

        # --- Strategy 2: Cross-Exchange Divergence ---
        if len(coin_rates) >= 2:
            exchanges = list(coin_rates.keys())
            for i in range(len(exchanges)):
                for j in range(i + 1, len(exchanges)):
                    ex_a = exchanges[i]
                    ex_b = exchanges[j]
                    rate_a = coin_rates[ex_a]
                    rate_b = coin_rates[ex_b]
                    spread = abs(rate_a - rate_b)

                    if spread >= threshold:
                        # Long on the exchange with lower (more negative) funding
                        # Short on the exchange with higher (more positive) funding
                        if rate_a > rate_b:
                            high_ex, low_ex = ex_a, ex_b
                        else:
                            high_ex, low_ex = ex_b, ex_a

                        action = f"long_{low_ex}_short_{high_ex}"
                        expected_profit = spread * leverage

                        opportunities.append({
                            "coin": coin,
                            "type": "cross_exchange_divergence",
                            "action": action,
                            "expected_profit_pct": expected_profit,
                            "price": price,
                            "size_usd": position_size,
                            "exchange_long": low_ex,
                            "exchange_short": high_ex,
                            "spread": spread,
                            "details": f"Spread: {spread*100:.4f}% ({low_ex} vs {high_ex})",
                        })

    # Sort by expected profit descending
    opportunities.sort(key=lambda x: x["expected_profit_pct"], reverse=True)
    return opportunities
