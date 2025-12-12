#!/bin/bash
set -euo pipefail

generate_root_ca() {
  local ca_name=$CA_NAME      # e.g. MyCustomCA
  local ca_days="${2:-365}"     # optional validity days (default: 1 years)

  local ca_dir="$CERTS_DIR/ca"
  local ca_key="$ca_dir/ca.key"
  local ca_cert="$ca_dir/ca.crt"

  # === Prepare ca folder ===
  if [[ -d "$ca_dir" ]]; then
    rm -rf "$ca_dir"/*
  else
    mkdir -p "$ca_dir"
  fi

  # Step 1: Generate CA private key (ECC P-521)
  echo "Generating Root CA private key (ECC P-521)..."
  openssl genpkey \
      -algorithm EC \
      -pkeyopt ec_paramgen_curve:secp521r1 \
      -out "$ca_key"

  # Step 2: Generate Root CA certificate (self-signed)
  echo "Generating self-signed Root CA certificate..."
  openssl req -x509 -new -nodes -key "$ca_key" \
      -sha512 -days "$ca_days" \
      -subj "/C=${SUBJ_C}/ST=${SUBJ_ST}/L=${SUBJ_L}/O=${SUBJ_O}/OU=${SUBJ_OU}/CN=${ca_name}" \
      -out "$ca_cert"

  chmod 600 "$ca_key"
  chmod 644 "$ca_cert"

  echo -e "\nRoot CA generated successfully:"
  echo " - CA Key:  $ca_key"
  echo " - CA Cert: $ca_cert"
  echo "=========================================================================="
}

# ===== Example usage =====
# generate_root_ca "LDNhanCA"
# generate_root_ca "ExampleCA" 730

generate_cert_with_keystore_and_truststore() {
  local cert_dir="$CERTS_DIR/$1"  # absolute or relative path
  local main_domain="$2"          # e.g. example.com

  shift 2
  local sub_domains=("$@")        # array: sub1.example.com sub2.example.com

  local alias_name="${main_domain//./-}"
  local cert_secret=${CERT_SECRET:?❌ CERT_SECRET is not set}
  local ca_cert="$CERTS_DIR/ca/ca.crt"
  local ca_key="$CERTS_DIR/ca/ca.key"

  # === Prepare cert folder ===
  if [[ -d "$cert_dir" ]]; then
    rm -rf "$cert_dir"/*
  else
    mkdir -p "$cert_dir"
  fi

  # === Generate private key (ECC P-521) ===
  echo "Generating private key (ECC P-521)..."
  openssl genpkey \
    -algorithm EC \
    -pkeyopt ec_paramgen_curve:secp521r1 \
    -out "$cert_dir/$alias_name.key.pem"

  openssl genpkey \
    -algorithm EC \
    -pkeyopt ec_paramgen_curve:secp521r1 \
    -out "$cert_dir/$alias_name.key"

  # === Create OpenSSL config ===
  echo "Creating OpenSSL config with SANs..."
  local san_text=""
  local count=1
  san_text+="DNS.${count} = ${main_domain}\n"; ((count++))
  san_text+="DNS.${count} = localhost\n"; ((count++))
  san_text+="DNS.${count} = 127.0.0.1\n"; ((count++))

  # Only add extra subdomains if provided
  if [[ ${#sub_domains[@]} -gt 0 ]]; then
    for sub in "${sub_domains[@]}"; do
      if [[ -n "$sub" ]]; then
        san_text+="DNS.${count} = ${sub}\n"
        ((count++))
      fi
    done
  fi

  cat > "$cert_dir/$alias_name.openssl.cnf" << EOF
[ req ]
prompt             = no
default_md         = sha512
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C = ${SUBJ_C}
ST = ${SUBJ_ST}
L = ${SUBJ_L}
O = ${SUBJ_O}
OU = ${SUBJ_OU}
CN = ${main_domain}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
$(printf "$san_text")
EOF

  # === Generate CSR ===
  echo "Generating certificate signing request (CSR)..."
  openssl req -new \
    -key "$cert_dir/$alias_name.key.pem" \
    -out "$cert_dir/$alias_name.csr.pem" \
    -config "$cert_dir/$alias_name.openssl.cnf"

  openssl req -new \
    -key "$cert_dir/$alias_name.key" \
    -out "$cert_dir/$alias_name.csr" \
    -config "$cert_dir/$alias_name.openssl.cnf"

  # === Sign cert with CA ===
  echo "Signing certificate with CA..."
  openssl x509 -req \
    -in "$cert_dir/$alias_name.csr.pem" \
    -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial \
    -out "$cert_dir/$alias_name.cert.pem" -days 365 -sha512 \
    -extfile "$cert_dir/$alias_name.openssl.cnf" -extensions req_ext

  openssl x509 -req \
    -in "$cert_dir/$alias_name.csr" \
    -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial \
    -out "$cert_dir/$alias_name.crt" -days 365 -sha512 \
    -extfile "$cert_dir/$alias_name.openssl.cnf" -extensions req_ext

  # === Create PKCS#12 keystore ===
  echo "Creating PKCS#12 keystore..."
  openssl pkcs12 -export \
    -inkey "$cert_dir/$alias_name.key.pem" \
    -in "$cert_dir/$alias_name.cert.pem" \
    -certfile "$ca_cert" \
    -passout pass:"$cert_secret" \
    -out "$cert_dir/$alias_name.keystore.p12" \
    -name "$alias_name"

  # === Create PKCS#12 truststore ===
  echo "Creating PKCS#12 truststore..."
  keytool -importcert \
    -noprompt \
    -trustcacerts \
    -alias "$CA_NAME" \
    -file "$ca_cert" \
    -keystore "$cert_dir/$alias_name.truststore.p12" \
    -storetype PKCS12 \
    -storepass "$cert_secret"

  # === Permissions ===
  chmod 644 "$cert_dir"/*.pem "$cert_dir"/*.p12 "$cert_dir"/*.csr "$cert_dir"/*.crt

  echo "[$main_domain] All certs, Keystore and truststore generation complete!"
  echo "=========================================================================="
}

# ===== Example usage =====
# export CERT_SECRET="yourpass"
# generate_keystore_and_truststore "/path/to/certs" "example.com" "rest_api.example.com" "admin.example.com"
