# Developing on macOS
**NOTE: This documentation is still a work-in-progress!**

This guide will introduce you to deploying and working on the Acasi CTF platform on macOS by
utilizing minikube.

**This guide assumes you are using an Intel Mac, these instructions have not been tested on an Apple
Silicon Mac, yet.**

## Prerequisites
* Homebrew
* Docker Desktop (optional, read [this](#macos-beta-users))
* Xcode
* Xcode Command Line Utilities

# Install utilities
```
brew install minikube kubectx kubectl helm kustomize fzf
```

# Start minikube
## Warning: macOS beta users
If you are running the macOS 12.0 Monterey beta, you may need to use the Docker driver instead of
the HyperKit driver, which is the default. If you do not, you might hit an error where minikube
times out while trying to start the VM. Do this by running the following command before starting it.
```
minikube config set driver docker
```

## Starting minikube

Start minikube by running the start subcommand.
```
minikube start
```
