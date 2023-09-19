# EC2 Instance
resource "aws_instance" "ecomm-web" {
  ami           = "ami-0d50e9ae42eead5cd"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.ecomm-pub-sn.id
  vpc_security_group_ids = [aws_security_group.ecomm-pub-sg.id]
  key_name = "ravi-key"
  user_data = file("ecomm.sh")
  tags = {
    Name = "ecomm-server"
  }
}