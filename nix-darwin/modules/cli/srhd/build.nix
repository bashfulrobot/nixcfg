{ fetchFromGitHub, rustPlatform, }:
rustPlatform.buildRustPackage rec {
  pname = "srhd";
#   TODO: Updates
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "sylvanfranklin";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-hku7LxxudUTMhZ63c9+HKBVclrYqDPQU9WnqMl/4wjo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-5NuN9MopzigbmhI6PO0NV0BPqYLNEMA/51lK6750VvE=";
}
