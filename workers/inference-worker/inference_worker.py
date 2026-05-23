import os
from typing import Any, Dict
from iii import InitOptions, Logger, register_worker

iii = register_worker(
    os.environ.get("III_URL", "ws://localhost:49134"),
    InitOptions(worker_name="math-worker"),
)
logger = Logger()

import urllib.request
import json

def run_inference_handler(payload: Dict[str, Any]) -> Dict[str, Any]:
    messages = payload.get("messages", [])
    api_key = os.environ.get("GROQ_API_KEY", "")
    data = json.dumps({
        "model": "llama3-8b-8192",
        "messages": messages,
        "max_tokens": 200
    }).encode("utf-8")
    req = urllib.request.Request(
        "https://api.groq.com/openai/v1/chat/completions",
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    )
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode())
    response_text = result["choices"][0]["message"]["content"]
    print(response_text)
    return {"response": response_text}

iii.register_function("inference::run_inference", run_inference_handler)
print("Inference worker started - listening for calls")
