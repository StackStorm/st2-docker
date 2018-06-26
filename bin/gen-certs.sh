#!/bin/bash

set -euo pipefail

SSL_DIR=ssl

ST2_KEY=${SSL_DIR}/st2.key
ST2_CRT=${SSL_DIR}/st2.crt

mkdir -p ${SSL_DIR}
openssl req -x509 -newkey rsa:2048 -keyout ${ST2_KEY} -out ${ST2_CRT} -days 3650 -nodes -subj '/O=st2 self signed/CN=localhost'
