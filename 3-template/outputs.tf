
# Output 
output "aws_ip_01" {
  value = aws_eip.one.public_ip
}
output "aws_ip_02" {
  value = aws_eip.two.public_ip
}