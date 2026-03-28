"""
FinAI — Funding Arbitrage Server
FastAPI backend with WebSocket state broadcasting, REST API, and background scanning.
"""

import asyncio
import json
import logging
import time
from contextlib import asynccontextmanager
from typing import Any, Dict, List, Optional, Set

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from engine import detect_opportunities
from exchanges import fetch_all_funding_rates, fetch_prices
from positions import PositionManager

# ── Logging ──────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("finai.server")

# ── Global State ─────────────────────────────────────────────────────────────
config: Dict[str, Any] = {
    "position_size": 100,
    "leverage": 5,
    "max_positions": 5,
    "funding_threshold": 0.00001,
    "scan_interval": 15,
    "stop_loss_pct": 0.02,
    "take_profit_pct": 0.05,
    "dry_run": True,
    "running": False,
}

funding_rates: Dict[str, Dict[str, float]] = {
    "hyperliquid": {},
    "aevo": {},
    "dydx": {},
}
prices: Dict[str, float] = {}
opportunities: List[Dict[str, Any]] = []
last_scan: float = 0
scan_count: int = 0

position_manager = PositionManager()
connected_clients: Set[WebSocket] = set()

# ── Background Tasks ─────────────────────────────────────────────────────────
scan_task = None
broadcast_task = None


async def scan_loop():
    """Periodically scan for funding rate opportunities."""
    global funding_rates, prices, opportunities, last_scan, scan_count

    while True:
        try:
            if config.get("running", False):
                logger.info("Scanning funding rates...")

                # Fetch data from all exchanges concurrently
                new_rates, new_prices = await asyncio.gather(
                    fetch_all_funding_rates(),
                    fetch_prices(),
                )

                funding_rates.update(new_rates)
                if new_prices:
                    prices.update(new_prices)

                # Update position prices
                position_manager.update_prices(prices)

                # Detect opportunities
                opportunities = detect_opportunities(funding_rates, prices, config)

                last_scan = time.time() * 1000
                scan_count += 1

                logger.info(
                    f"Scan #{scan_count}: {len(opportunities)} opportunities, "
                    f"{len(prices)} prices, "
                    f"HL:{len(funding_rates.get('hyperliquid', {}))} "
                    f"Aevo:{len(funding_rates.get('aevo', {}))} "
                    f"dYdX:{len(funding_rates.get('dydx', {}))}"
                )

            interval = config.get("scan_interval", 15)
            await asyncio.sleep(interval)

        except asyncio.CancelledError:
            break
        except Exception as e:
            logger.error(f"Scan error: {e}")
            await asyncio.sleep(5)


async def broadcast_loop():
    """Broadcast state to all connected WebSocket clients every second."""
    while True:
        try:
            if connected_clients:
                state = get_full_state()
                message = json.dumps({"type": "state_update", "data": state})
                disconnected = set()
                for client in connected_clients:
                    try:
                        await client.send_text(message)
                    except Exception:
                        disconnected.add(client)
                connected_clients.difference_update(disconnected)

            await asyncio.sleep(1)
        except asyncio.CancelledError:
            break
        except Exception as e:
            logger.error(f"Broadcast error: {e}")
            await asyncio.sleep(1)


def get_full_state() -> Dict[str, Any]:
    """Build the complete state object for the frontend."""
    pm_state = position_manager.get_state()
    return {
        "running": config.get("running", False),
        "config": config,
        "funding_rates": funding_rates,
        "prices": prices,
        "opportunities": opportunities,
        "positions": pm_state["positions"],
        "trade_log": pm_state["trade_log"],
        "equity": pm_state["equity"],
        "total_pnl": pm_state["total_pnl"],
        "last_scan": last_scan,
        "scan_count": scan_count,
    }


# ── App Lifecycle ────────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    global scan_task, broadcast_task
    scan_task = asyncio.create_task(scan_loop())
    broadcast_task = asyncio.create_task(broadcast_loop())
    logger.info("FinAI server started — background tasks running")
    yield
    scan_task.cancel()
    broadcast_task.cancel()
    logger.info("FinAI server shutting down")


# ── FastAPI App ──────────────────────────────────────────────────────────────
app = FastAPI(title="FinAI Funding Arbitrage", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── WebSocket ────────────────────────────────────────────────────────────────
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connected_clients.add(websocket)
    logger.info(f"WebSocket client connected ({len(connected_clients)} total)")

    # Send initial state immediately
    try:
        state = get_full_state()
        await websocket.send_text(json.dumps({"type": "state_update", "data": state}))
    except Exception:
        pass

    try:
        while True:
            # Keep connection alive, handle incoming messages
            data = await websocket.receive_text()
            # Client messages could be used for future features
    except WebSocketDisconnect:
        pass
    finally:
        connected_clients.discard(websocket)
        logger.info(f"WebSocket client disconnected ({len(connected_clients)} total)")


# ── REST API ─────────────────────────────────────────────────────────────────
class ConfigUpdate(BaseModel):
    position_size: Optional[float] = None
    leverage: Optional[int] = None
    max_positions: Optional[int] = None
    funding_threshold: Optional[float] = None
    scan_interval: Optional[int] = None
    stop_loss_pct: Optional[float] = None
    take_profit_pct: Optional[float] = None
    dry_run: Optional[bool] = None
    running: Optional[bool] = None


@app.post("/api/config")
async def update_config(update: ConfigUpdate):
    """Update bot configuration."""
    data = update.model_dump(exclude_none=True)
    config.update(data)
    logger.info(f"Config updated: {data}")
    return {"status": "ok", "config": config}


@app.post("/api/scan")
async def manual_scan():
    """Trigger a manual funding rate scan."""
    global funding_rates, prices, opportunities, last_scan, scan_count

    logger.info("Manual scan triggered")
    new_rates, new_prices = await asyncio.gather(
        fetch_all_funding_rates(),
        fetch_prices(),
    )

    funding_rates.update(new_rates)
    if new_prices:
        prices.update(new_prices)

    position_manager.update_prices(prices)
    opportunities = detect_opportunities(funding_rates, prices, config)

    last_scan = time.time() * 1000
    scan_count += 1

    return {
        "status": "ok",
        "opportunities": len(opportunities),
        "scan_count": scan_count,
    }


class ExecuteRequest(BaseModel):
    opportunity: Dict[str, Any]


@app.post("/api/execute")
async def execute_opportunity(req: ExecuteRequest):
    """Execute a trading opportunity (opens a position in dry-run mode)."""
    opp = req.opportunity

    if len(position_manager.positions) >= config.get("max_positions", 5):
        return {"status": "error", "message": "Max positions reached"}

    # Check if we already have a position on this coin
    for pos in position_manager.positions:
        if pos["coin"] == opp.get("coin"):
            return {"status": "error", "message": f"Already have position on {opp['coin']}"}

    position = position_manager.open_position(
        coin=opp.get("coin", "UNKNOWN"),
        action=opp.get("action", "long"),
        price=opp.get("price", 0),
        size_usd=opp.get("size_usd", config["position_size"]),
        leverage=config["leverage"],
        stop_loss_pct=config["stop_loss_pct"],
        take_profit_pct=config["take_profit_pct"],
    )

    if position:
        return {"status": "ok", "position": position}
    return {"status": "error", "message": "Failed to open position"}


@app.post("/api/close/{position_id}")
async def close_position(position_id: str):
    """Close an open position."""
    pos = position_manager.close_position(position_id, reason="manual")
    if pos:
        return {"status": "ok", "closed": pos}
    return {"status": "error", "message": "Position not found"}


# ── Static Files ─────────────────────────────────────────────────────────────
@app.get("/")
async def serve_index():
    return FileResponse("static/index.html")


app.mount("/static", StaticFiles(directory="static"), name="static")


# ── Entry Point ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
