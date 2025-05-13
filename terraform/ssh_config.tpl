%{ for node in node_name ~}
Host ${node}
  Hostname ${node_ip}
  User ${user_name}
  IdentitiesOnly yes
  IdentityFile ${ssh_identity_file}
  ProxyJump homelab-test
%{ endfor ~}
