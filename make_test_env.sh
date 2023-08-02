#!/bin/sh

nix build .
mkdir -p test_env
nix copy --to ./test_env $(realpath result) --no-check-sigs
mkdir -p test_env/bin test_env/dev test_env/etc/config
test -d source || git clone https://git.openwrt.org/project/odhcpd.git source
nix develop --command cmake -S source -B source/build
nix develop --command cmake --build source/build
cp ./source/build/odhcpd ./test_env/bin/odhcpd

sudo chroot ./test_env /bin/odhcpd -l7

