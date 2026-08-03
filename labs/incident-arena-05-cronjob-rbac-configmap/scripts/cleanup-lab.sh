#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace incident-arena-05 --ignore-not-found=true
