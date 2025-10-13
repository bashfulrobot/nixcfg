{ lib, stdenv, writeShellScriptBin, nodejs, cacert }:

writeShellScriptBin "sitemcp" ''
  export PATH="${nodejs}/bin:$PATH"
  export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
  exec npx sitemcp@0.5.9 "$@"
''