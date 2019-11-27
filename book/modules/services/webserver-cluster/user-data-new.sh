#! /bin/bash

cat > index.html <<EOF
<h1>Hello, World version 2</h1>
EOF

nohup busybox httpd -f -p ${server_port} &

