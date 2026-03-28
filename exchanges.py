"""
Exchange funding rate fetchers for Hyperliquid, Aevo, and dYdX.
All fetchers return dict[str, float] mapping coin symbol -> funding rate (as decimal).
"""

import asyncio
import logging
from typing import Dict, Optional

import httpx

logger = logging.getLogger("finai.exchanges")

TRACKED_COINS = ["BTC", "ETH", "SOL", "ARB", "DOGE", "AVAX", "MATIC", "LINK", "OP", "SUI"]

TIMEOUT = httpx.Timeout(10.0, connect=5.0)


async def fetch_hyperliquid_funding() -> Dict[str, float]:
    """Fetch current funding rates from Hyperliquid."""
    rates: Dict[str, float] = {}
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            resp = await client.post(
                "https://api.hyperliquid.xyz/info",
                json={"type": "metaAndAssetCtxs"},
            )
            resp.raise_for_status()
            data = resp.json()

            if isinstance(data, list) and len(data) >= 2:
                meta = data[0]
                asset_ctxs = data[1]
                universe = meta.get("universe", [])

                for i, asset in enumerate(universe):
                    symbol = asset.get("name", "").upper()
                    if symbol in TRACKED_COINS and i < len(asset_ctxs):
                        ctx = asset_ctxs[i]
                        funding = ctx.get("funding")
                        if funding is not None:
                            rates[symbol] = float(funding)
    except Exception as e:
        logger.warning(f"Hyperliquid fetch error: {e}")
    return rates


async def fetch_hyperliquid_prices() -> Dict[str, float]:
    """Fetch current mid prices from Hyperliquid."""
    prices: Dict[str, float] = {}
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            resp = await client.post(
                "https://api.hyperliquid.xyz/info",
                json={"type": "metaAndAssetCtxs"},
            )
            resp.raise_for_status()
            data = resp.json()

            if isinstance(data, list) and len(data) >= 2:
                meta = data[0]
                asset_ctxs = data[1]
                universe = meta.get("universe", [])

                for i, asset in enumerate(universe):
                    symbol = asset.get("name", "").upper()
                    if symbol in TRACKED_COINS and i < len(asset_ctxs):
                        ctx = asset_ctxs[i]
                        mark_px = ctx.get("markPx")
                        if mark_px is not None:
                            prices[symbol] = float(mark_px)
    except Exception as e:
        logger.warning(f"Hyperliquid price fetch error: {e}")
    return prices


async def fetch_aevo_funding() -> Dict[str, float]:
    """Fetch current funding rates from Aevo."""
    rates: Dict[str, float] = {}

    async def _fetch_one(client: httpx.AsyncClient, coin: str):
        try:
            resp = await client.get(
                f"https://api.aevo.xyz/funding",
                params={"instrument_name": f"{coin}-PERP"},
            )
            if resp.status_code == 200:
                data = resp.json()
                if isinstance(data, dict):
                    funding = data.get("funding_rate")
                    if funding is not None:
                        rates[coin] = float(funding)
                elif isinstance(data, list) and len(data) > 0:
                    entry = data[-1] if isinstance(data[-1], dict) else data[0]
                    funding = entry.get("funding_rate") or entry.get("rate")
                    if funding is not None:
                        rates[coin] = float(funding)
        except Exception as e:
            logger.debug(f"Aevo fetch error for {coin}: {e}")

    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            tasks = [_fetch_one(client, coin) for coin in TRACKED_COINS]
            await asyncio.gather(*tasks)
    except Exception as e:
        logger.warning(f"Aevo batch fetch error: {e}")
    return rates


async def fetch_dydx_funding() -> Dict[str, float]:
    """Fetch current funding rates from dYdX v4."""
    rates: Dict[str, float] = {}

    # dYdX v4 uses different ticker format
    dydx_map = {
        "BTC": "BTC-USD",
        "ETH": "ETH-USD",
        "SOL": "SOL-USD",
        "ARB": "ARB-USD",
        "DOGE": "DOGE-USD",
        "AVAX": "AVAX-USD",
        "MATIC": "MATIC-USD",
        "LINK": "LINK-USD",
        "OP": "OP-USD",
        "SUI": "SUI-USD",
    }

    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            # dYdX v4 indexer API
            resp = await client.get(
                "https://indexer.dydx.trade/v4/perpetualMarkets",
            )
            if resp.status_code == 200:
                data = resp.json()
                markets = data.get("markets", {})
                for coin, ticker in dydx_map.items():
                    market = markets.get(ticker)
                    if market:
                        # nextFundingRate is the predicted next funding rate
                        funding = market.get("nextFundingRate")
                        if funding is not None:
                            rates[coin] = float(funding)
    except Exception as e:
        logger.warning(f"dYdX fetch error: {e}")
    return rates


async def fetch_all_funding_rates() -> Dict[str, Dict[str, float]]:
    """Fetch funding rates from all exchanges concurrently."""
    hl_rates, aevo_rates, dydx_rates = await asyncio.gather(
        fetch_hyperliquid_funding(),
        fetch_aevo_funding(),
        fetch_dydx_funding(),
    )
    return {
        "hyperliquid": hl_rates,
        "aevo": aevo_rates,
        "dydx": dydx_rates,
    }


async def fetch_prices() -> Dict[str, float]:
    """Fetch latest prices (using Hyperliquid as primary source)."""
    return await fetch_hyperliquid_prices()
