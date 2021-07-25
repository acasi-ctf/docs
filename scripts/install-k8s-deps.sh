#!/usr/bin/env bash
set -e

cd /usr/local/bin

echo "Preparing..."
unlink kubectl 2> /dev/null || true

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl

echo "Installing minikube..."
curl -L "https://github.com/kubernetes/minikube/releases/download/v1.22.0/minikube-linux-amd64" --output minikube
chmod +x minikube

echo "Installing kustomize..."
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.2.0/kustomize_v4.2.0_linux_amd64.tar.gz" --output kustomize.tar.gz
tar xzf kustomize.tar.gz
chmod +x kustomize
rm kustomize.tar.gz

echo "Installing helm..."
curl -L "https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz" --output helm.tar.gz
tar xzf helm.tar.gz
mv linux-amd64/helm .
chmod +x helm
rm -r linux-amd64
rm helm.tar.gz

echo "Installing kubectx and kubens..."
curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz" --output kubectx.tar.gz
tar xzf kubectx.tar.gz
rm kubectx.tar.gz
curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_linux_x86_64.tar.gz" --output kubens.tar.gz
tar xzf kubens.tar.gz
rm kubens.tar.gz

echo "Installing final dependencies from apt..."
apt-get update
apt-get install -y fzf

echo "kubectl, minikube, kustomize, helm, kubectx, and kubens have been installed successfully!"
