#!/bin/sh
cat $(find $ADD_CA_PATH -name *.crt) >> /etc/ssl/certs/ca-certificates.crt
rm $0
