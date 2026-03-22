resource "aws_instance" "k3s_node" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  vpc_security_group_ids      = [aws_security_group.k3s_testing_sg.id]
  key_name                    = var.key_name
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata/bootstrap.sh.tpl", {
    k3s_version       = var.k3s_version
    functions_sh      = file("${path.module}/userdata/functions.sh.tpl")
    system_setup_sh   = file("${path.module}/userdata/system-setup.sh.tpl")
    k3s_install_sh    = file("${path.module}/userdata/k3s-install.sh.tpl")
    shell_setup_sh    = file("${path.module}/userdata/shell-setup.sh.tpl")
    argocd_bootstrap  = file("${path.module}/userdata/argocd-bootstrap.sh.tpl")
    cleanup_sh        = file("${path.module}/userdata/cleanup.sh.tpl")
  })

  tags = merge(local.common_tags, {
    Name = var.instance_name
  })
}