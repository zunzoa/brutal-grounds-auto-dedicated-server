resource "null_resource" "waiter" {

  depends_on = [aws_instance.bg_ec2]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = aws_instance.bg_ec2.public_ip
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connected!'",
      "ping google.com -c 1 -W 1 && { echo 'Internet network access established!'; } || exit 1 ",
      "echo 'Instance is alive!'"
    ]
  }

  provisioner "file" {
    source = "cloud-init-wait.sh"
    destination = "/tmp/cloud-init-wait.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/cloud-init-wait.sh",
      "/tmp/cloud-init-wait.sh",
      "echo 'Cloud init finished!'"
    ]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/host.yaml ../ansible/playbook.yaml --extra-vars 'server_ip=${aws_instance.bg_ec2.public_ip} private_key=${var.PATH_TO_PRIVATE_KEY}'"
    interpreter = ["/bin/bash", "-c"]
  }
}