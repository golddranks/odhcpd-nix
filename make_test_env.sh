#!/bin/sh

nix build .
mkdir -p test_env
nix copy --to ./test_env $(realpath result) --no-check-sigs
mkdir -p test_env/bin test_env/proc/net test_env/dev test_env/etc/config
test -d source || git clone https://git.openwrt.org/project/odhcpd.git source
nix develop --command cmake -S source -B source/build
nix develop --command cmake --build source/build -v
cp ./source/build/odhcpd ./test_env/bin/odhcpd
sudo mknod ./test_env/dev/urandom c 1 9
cat > ./test_env/proc/net/ipv6_route <<EOF
00000000000000000000000000000000 00 00000000000000000000000000000000 00 00000000000000000000000000000000 00000100 0000000b 00000000 00000001     eno1
EOF

sudo chroot ./test_env /bin/odhcpd -l7

