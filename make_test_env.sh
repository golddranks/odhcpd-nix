#!/bin/sh

nix build .
mkdir -p test_env
nix copy --to ./test_env $(realpath result) --no-check-sigs
mkdir -p test_env/bin test_env/dev test_env/etc/config
nix develop --command cmake --fresh -S src -B src/build
nix develop --command cmake --build src
cp src/odhcpd ./test_env/bin/odhcpd
sudo chroot ./test_env /bin/odhcpd -l7

