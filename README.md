# Alchemyst DevOps Internship Assignment

## Architecture

    Internet
        |
        v (port 3111)
    gateway-vm [PUBLIC IP]
        |
        | RPC via WebSocket (port 49134)
        |
    inference-vm [PRIVATE ONLY]

    Both VMs inside GCP VPC private subnet 10.0.1.0/24

## Workers

| Worker | Language | VM | Function |
|---|---|---|---|
| inference-worker | Python | inference-vm | Loads gemma-3-270m GGUF, runs inference |
| caller-worker | TypeScript | gateway-vm | HTTP trigger, calls inference via RPC |

## API

    curl -X POST http://GATEWAY_PUBLIC_IP:3111/v1/chat/completions -H 'Content-Type: application/json' -d '{"messages": [{"role": "user", "content": "Hello"}]}'

Sample response:

    {"result":{"response":"Hello!","success":"Workers interoperating seamlessly."}}

## Redeploy from Scratch

1. git clone https://github.com/Suryansh0910/alchemyst-devops-assignment.git
2. gcloud auth application-default login
3. gcloud config set project alchemyst-devops-2026
4. gcloud services enable compute.googleapis.com
5. cd terraform && terraform init && terraform apply
6. Wait 5 minutes, curl using gateway_public_ip from terraform output

## Production Hardening

- HTTPS via nginx + Lets Encrypt on gateway
- API key auth middleware on HTTP endpoint
- GCP Secret Manager for secrets
- Restrict SSH firewall to specific IPs only
- GCP Cloud Logging and uptime monitoring
- Service accounts with minimal IAM permissions

## Scaling to 100x Larger Model

- GPU instance with NVIDIA T4 for inference-vm
- Store model weights in GCS bucket, mount at boot
- Multiple inference-worker replicas behind load balancer
- GKE for auto-scaling inference pods
- Q4 quantization instead of Q8 to cut memory in half
- Model sharding across multiple VMs
