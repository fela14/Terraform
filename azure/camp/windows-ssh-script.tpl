cat << EOF >> ~/.ssh/config
Host ${hostname}
    HostName ${public_ip}
    User ${user}
    IdentityFile ${identityFile}
    StrictHostKeyChecking no
EOF

echo "Added SSH configuration for ${hostname} (${public_ip})"
