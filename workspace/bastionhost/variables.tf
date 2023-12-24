locals {
  vpc_id       = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  ssh_port     = 22
  ssh1_port =3223
  tcp_protocol = "tcp"
  all_network  = "0.0.0.0/0"
  any_port     = "0"
  any_protocol = "-1"
}