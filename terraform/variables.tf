variable "project_id" {
  description = "mystic-song-410112"
  type        = string
}
variable "cluster_name" {
  default = "live-talking"
}

variable "region" {
  default = "asia-south1"
}

variable "zone" {
  default = "asia-south1-a"
}

variable "default_machine_type" {
  description = "Machine type for default node pool"
  type        = string
  default     = "n1-standard-4"
}

# GPU Node Pool variables
variable "gpu_machine_type" {
  description = "Machine type for GPU node pool"
  type        = string
  default     = "n1-standard-4"
}

variable "gpu_type" {
  description = "GPU accelerator type"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count" {
  description = "Number of GPUs per node"
  type        = number
  default     = 1
}

variable "gpu_min_nodes" {
  description = "Minimum GPU nodes"
  type        = number
  default     = 0
}

variable "gpu_max_nodes" {
  description = "Maximum GPU nodes"
  type        = number
  default     = 1
}

variable "gpu_initial_nodes" {
  description = "Initial GPU nodes"
  type        = number
  default     = 0
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

variable "default_node_count" {
  description = "Initial node count for default CPU node pool"
  type        = number
  default     = 1
}

variable "default_min_nodes" {
  description = "Minimum nodes for default CPU node pool autoscaling"
  type        = number
  default     = 1
}

variable "default_max_nodes" {
  description = "Maximum nodes for default CPU node pool autoscaling"
  type        = number
  default     = 3
}
