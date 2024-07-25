#!/bin/bash

terraform output -json public_ip > inventory.json

jq -r '"[web]\n" + . + " ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/trecom/.ssh/web02.pem"' inventory.json > inventory.ini