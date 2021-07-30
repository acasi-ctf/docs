# Developing on macOS
**NOTE: This documentation is still a work-in-progress!**

This guide will introduce you to deploying and working on the Acasi CTF platform on macOS by
utilizing minikube.

## Prerequisites
* Homebrew
* Docker Desktop (optional, read [this](#start-minikube))
* Xcode
* Xcode Command Line Utilities

# Install utilities
```
brew install minikube kubectx kubectl helm kustomize fzf
```

# Start minikube
**macOS beta users**: If you are running the macOS 12.0 Monterey beta, you may need to use the
Docker driver instead of the HyperKit driver.
```
minikube config set driver docker
```

Start minikube by running the start subcommand.
```
minikube start
```
