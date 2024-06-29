#!/usr/bin/env bash

# Create config file with this content
[ req ]
default_bits           = 4096
distinguished_name     = req_distinguished_name
req_extensions         = req_ext

[ req_distinguished_name ]
countryName            = IT
stateOrProvinceName    = State or Province Name (full name)
localityName           = Locality Name (eg, city)
organizationName       = Organization Name (eg, company)
commonName             = Sandro

# Optionally, specify some defaults.
countryName_default           = [Country]
stateOrProvinceName_default   = [State]
localityName_default           = [City]
0.organizationName_default     = [Organization]
organizationalUnitName_default = [Organization unit]
emailAddress_default           = [Email]

[ req_ext ]
subjectAltName = @alt_names

[alt_names]
IP.1 = 10.0.0.5
IP.2 = 192.168.100.14

# Get Certificate Sign Request (CSR)
openssl req -newkey rsa:4096 -noenc -keyout key.key -out keycsr.csr -config openssl-san.cnf

# Verify request
openssl req -text -noout -verify -in keycsr.csr

# Sign request
openssl x509 -signkey key.key -in keycsr.csr -req -days 1000 -out domain.cert
