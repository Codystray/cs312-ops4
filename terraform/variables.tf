variable "key_name" {
  description = "Name of an existing AWS EC2 key pair (e.g., ~/.ssh/cs312-key.pem)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH to the instance. Set to your-ip/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.medium"
}

variable "backup_bucket" {
  description = "Name of the externally-managed S3 bucket holding world backups."
  type        = string
}

