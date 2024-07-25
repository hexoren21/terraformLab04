#!/bin/bash

terraform output -json public_ip > inventory.json

jq -r '"web ansible_host=" + .' inventory.json > inventory.ini