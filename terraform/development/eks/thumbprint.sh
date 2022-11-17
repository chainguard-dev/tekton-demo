#!/bin/bash

THUMBPRINT=$(echo | openssl s_client -servername $1 -showcerts -connect $1:443 2>&-  2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo "$THUMBPRINT_JSON"
