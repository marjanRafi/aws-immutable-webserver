output "web_server_ip" {
  description = "Public IP of the Immutable Web Server"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "Click here to see the server"
  value       = "http://${aws_instance.web_server.public_ip}"
}