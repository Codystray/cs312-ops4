output "instance_public_ip" {
  description = "Public IPv4 address of the k3s host"
  value       = aws_instance.minecraft.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.minecraft.id
}

output "ssh_command" {
  description = "Ready-to-paste SSH command (Ubuntu default user is ubuntu)"
  value       = "ssh -i ~/.ssh/cs312-key.pem ubuntu@${aws_instance.minecraft.public_ip}"
}

output "minecraft_endpoint" {
  description = "Address players connect to"
  value       = "${aws_instance.minecraft.public_ip}:25565"
}

output "ecr_repository_url" {
  description = "ECR repository URL (read from data source)"
  value       = data.aws_ecr_repository.minecraft.repository_url
}

output "backup_bucket_name" {
  description = "S3 bucket holding world backups (read from data source)"
  value       = data.aws_s3_bucket.backups.id
}
