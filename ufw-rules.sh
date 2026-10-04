#!/bin/sh

# --------------------------------------------------
# Source of truth for ufw rules.
#
# I use my Linux desktop computer as a local server
# for my web services (port 80). And DHCP in my router only
# provides addresses above 192.160.0.127, all
# addresses below that are reserved for specific devices
# that I own and trust. Here I define what ports
# are open to both kinds of devices in the local network.
#
# Run this to edit ufw rules in a declarative way
# --------------------------------------------------

set -e

LAN=192.168.0.0/24 # 192.168.0.0 - 192.168.0.255
TRUSTED=192.168.0.0/25 # 192.168.0.0 - 192.168.0.127

# Remove all existing user rules (keeps before/after.rules and defaults intact)
while ufw status numbered | grep -q '^\['; do
    ufw --force delete 1
done

ufw default deny incoming
ufw default allow outgoing

# All devices
ufw allow from "$LAN" to any port 5353 proto udp comment 'mdns: avahi'
ufw allow from "$LAN" to any port 53317 comment 'localsend'

# Trusted devices only
ufw allow from "$TRUSTED" to any port 22 proto tcp comment 'ssh'
ufw allow from "$TRUSTED" to any port 445 proto tcp comment 'samba'
ufw allow from "$TRUSTED" to any port 80 proto tcp comment 'caddy: web services'

ufw --force enable
ufw status numbered
