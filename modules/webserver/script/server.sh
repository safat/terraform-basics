#!/bin/bash
echo "<h1>Hello World</h1>" > index.html
echo "</br>DB Address: ${db_address}" >> index.html
echo "</br>User Text: ${user_text}" >> index.html
nohup busybox httpd -f -p "${server_port}" &
