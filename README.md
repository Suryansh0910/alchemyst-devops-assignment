# Alchemyst DevOps Internship Assignment

## Architecture

    Internet
        |
        v (port 3111)
    gateway-vm [PUBLIC IP]  ← caller-worker (TypeScript) + iii engine
        |
        | RPC via WebSocket (port 49134)
        |
    inference-vm [PRIVATE ONLY]  ← inference-worker (Python)

    Both VMs inside GCP VPC private subnet 10.0.1.0/24

## Workers

| Worker | Language | VM | Function |
|---|---|---|---|
| inference-worker | Python | inference-vm | Calls Gemini 2.5 Flash, returns inference result |
| caller-worker | TypeScript | gateway-vm | HTTP trigger, calls inference-worker via RPC |

## API

```bash
curl -X POST http://GATEWAY_PUBLIC_IP:3111/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello"}]}'
```

Sample response:

```json
{"result":{"response":"Hello! How can I help you today?","success":"You've connected two workers and they're interoperating seamlessly."}}
```

## Redeploy from Scratch

```bash
# 1. Clone the repo
git clone https://github.com/Suryansh0910/alchemyst-devops-assignment.git
cd alchemyst-devops-assignment

# 2. Authenticate with GCP
gcloud auth application-default login
gcloud config set project alchemyst-devops-2026
gcloud services enable compute.googleapis.com

# 3. Deploy with Terraform (will prompt for your Gemini API key)
cd terraform
terraform init
terraform apply
# Enter your Gemini API key when prompted

# 4. Wait ~5 minutes for VMs to boot and install dependencies
# 5. Test the endpoint
curl -X POST http://$(terraform output -raw gateway_public_ip):3111/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello"}]}'
```

## Production Hardening

- HTTPS via nginx + Let's Encrypt on gateway
- API key auth middleware on HTTP endpoint
- GCP Secret Manager for the Gemini API key instead of VM metadata
- Restrict SSH firewall to specific IPs only
- GCP Cloud Logging and uptime monitoring
- Service accounts with minimal IAM permissions

## Scaling to 100x Larger Model

- GPU instance (NVIDIA T4/A100) for inference-vm
- Store model weights in GCS bucket, mount at boot
- Multiple inference-worker replicas behind internal load balancer
- GKE for auto-scaling inference pods
- Q4 quantization to cut memory usage in half
- Model sharding across multiple VMs for very large models
