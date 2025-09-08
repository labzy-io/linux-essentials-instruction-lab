#!/usr/bin/env bash
set -e
ping -c 1 127.0.0.1 >/dev/null || { echo "FAIL: Localhost ping failed"; exit 1; }
(getent hosts example.com || dig +short example.com) >/dev/null || { echo "FAIL: DNS failed"; exit 1; }
echo "PASS: Networking Troubleshooting Completed"
