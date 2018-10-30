output "vpn_setup_command" {
    value = "${format("ssh openvpnas@%s", aws_instance.openvpn.public_ip)}"
}
output "vpn_web_console" {
  value = "${format("https://%s/", aws_instance.openvpn.public_ip)}"
}