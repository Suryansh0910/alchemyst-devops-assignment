import os
import json
import urllib.request
from typing import Any, Dict
from iii import InitOptions, Logger, register_worker

iii = register_worker(
    os.environ.get("III_URL", "ws://localhost:49134"),
    InitOptions(worker_name="inference-worker"),
)

logger = Logger()

def run_inference_handler(payload: Dict[str, Any]) -> Dict[str, Any]:
    messages = payload.get("messages", [])
    api_key = os.environ.get("GEMINI_API_KEY", "")
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set")

    gemini_messages = [
        {"role": "model" if m["role"] == "assistant" else m["role"],
         "parts": [{"text": m["content"]}]}
        for m in messages
    ]

    data = json.dumps({"contents": gemini_messages}).encode("utf-8")
    req = urllib.request.Request(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
        data=data,
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": api_key,
        },
    )

    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode())

    response_text = result["candidates"][0]["content"]["parts"][0]["text"]
    logger.info(f"Inference complete: {response_text[:80]}")
    return {"response": response_text}

iii.register_function("inference::run_inference", run_inference_handler)
logger.info("Inference worker started - listening for calls")
