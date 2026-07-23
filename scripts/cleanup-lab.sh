#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace incident-arena-02 --ignore-not-found
