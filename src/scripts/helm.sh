#!/usr/bin/env bash

set -e

install_base() {
    echo "=> Installing istio base..."
    kubectl create namespace istio-system
    helm install istio-base istio/base -n istio-system --set defaultRevision=default
    helm install istiod istio/istiod -n istio-system --wait
}

install_gateway() {
    echo "=> Installing istio gateway..."
    kubectl create namespace istio-ingress
    helm install istio-ingress istio/gateway -n istio-ingress --wait
}

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
install_base
install_gateway
