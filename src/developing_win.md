# Developing on Windows
**NOTE: This documentation is still a work-in-progress!**

This guide will introduce you to deploying and working on the Acasi CTF platform on Windows by
utilizing WSL 2 + Docker Desktop.

# Install WSL 2 and Docker Desktop
**TODO**

# Configure Docker Desktop
To use Docker from within our WSL 2 virtual machine, we need to enable the WSL 2 based engine from
within Docker Desktop. From the main Docker Desktop window, click the settings gear and check the
"Use the WSL 2 based engine" option.

![Enable the WSL 2 Docker Engine](images/docker_wsl2_step1.png)

Additionally, navigate to "Resources", then to "WSL Integration". Check both the "Enable integration
with my default WSL distro", and the "Ubuntu-20.04" slider.

![Enable Docker WSL Integration](images/docker_wsl2_step2.png)

After both of these steps have been taken, click the "Apply & Restart" button.

# Install Kubernetes utilities
The following script will download and install a few utilities that we are going to use in the rest
of this guide and for development on the platform.
```
curl https://raw.githubusercontent.com/acasi-ctf/docs/main/scripts/install-k8s-deps.sh | bash
```

# Prepare WSL2
## Create WSL user
In your WSL prompt, run the following, substituting USERNAME for the username of your choosing.
```
useradd -m USERNAME
gpasswd --add USERNAME sudo
```

Edit /etc/wsl.conf and insert the following contents, substituting USERNAME with your chosen username from the prior step.
```
[user]
default=USERNAME

[interop]
appendWindowsPath=false
```

## Configure minikube
```
minikube config set driver docker
minikube start
```

## Install dependencies
```
sudo apt install make
```

# Build Docker images
```
make docker
```

# Deploy Kubernetes manifests
```
kubectl create ns ctf
```

**TODO: Clone repo and checkout correct branch**

```
cd deploy
./generate_ssh_keys.sh minikube
kustomize build minikube > minikube.yaml
kubectl apply -f minikube.yaml
```
