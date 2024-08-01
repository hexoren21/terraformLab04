output "public_ips" {
  value       = [for instance in aws_instance.web : instance.public_ip]
  description = "Public IPs of the web instances"
}

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "DNS name of the ALB"
}
