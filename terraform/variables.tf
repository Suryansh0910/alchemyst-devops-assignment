variable "project_id" {
  description = "GCP Project ID"
  default     = "alchemyst-devops-2026"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "gemini_api_key" {
  description = "Gemini API key for inference worker"
  sensitive   = true
}
