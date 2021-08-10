# Developing on macOS
**NOTE: This documentation is still a work-in-progress!**

This guide will introduce you to deploying and working on the Acasi CTF platform on macOS by
utilizing minikube.

**This guide assumes you are using an Intel Mac, these instructions have not been tested on an Apple
Silicon Mac, yet.**

## Prerequisites
* Homebrew
* Docker Desktop (optional, read [this](#warning-macos-beta-users))
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

# Kubernetes pre-requisites
## Add Bitnami Helm repo
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

## Install Ingress controller
An ingress controller gives us the ability to run one web server which will proxy to one or more
backend servers, allowing us to share a single hostname between those multiple backend servers.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/cloud/deploy.yaml
```

## Add hosts entry
We need to add an entry to our local hosts file so that the "ctf" domain directs to our local web
server. The hosts files on macOS is located at /etc/hosts. As this is a system file, you must edit
it as an administrator.

The contents we want to add are as follows, do not remove anything from the file.
```
127.0.0.1 ctf
```

# Clone and build source
## Clone source
```
# Clone source from Git using SSH
git clone git@github.com:acasi-ctf/ctf.git

# Alternatively, use HTTPS if you don't have an SSH key installed
git clone https://github.com/acasi-ctf/ctf.git
```

**Temporary step: check out dev_docs_branch**
```
cd ctf
git checkout dev_docs
```

## Build Docker images
Now, build the Docker images for the platform. Ensure you're in the directory of the ctf repository.

```
# Activate the Docker environment
eval $(minikube -p minikube docker-env)

# Build docker images
make docker
```

# Deploy
## Create namespace
Kubernetes namespaces are a method of isolating resources, and is good practice to keep separate
projects in different namespaces for this reason.
```
# Create ctf namespace
kubectl create ns ctf

# Switch to new namespace
kubens ctf
```

## Create and deploy manifests
```
cd deploy

./generate_ssh_keys.sh minikube
cd minikube
helm install postgres bitnami/postgresql --values postgres-values.yaml
cd ..

kustomize build minikube > minikube.yaml
kubectl apply -f minikube.yaml
```

## Migrate the database
**This is a potential task for improvement.**

Currently, we need to manually migrate the PostgreSQL database. This is a fairly simple procedure,
but ideally would be automated in the future.

We need to get a shell for the pod that runs the frontend API. List the pods running in the ctf
namespace like so.
```
☁  ~  kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
ctf-frontend-f7f4f445f-bkxtc     1/1     Running   0          4m41s
ctf-operator-7d9868665-95xxh     1/1     Running   0          4m41s
ctf-termproxy-7b9858f47b-6gflw   1/1     Running   0          4m41s
ctf-ui-74d56f8d-dljnz            1/1     Running   0          4m40s
postgres-postgresql-0            1/1     Running   0          5m18s
```

Locate the pod that starts with `ctf-frontend`. Make a note of the full name, in our case it is
`ctf-frontend-584b4b9874-26vxx`. Execute a bash shell in the pod and run the commands as provided.
```
☁  ~  kubectl exec -it ctf-frontend-f7f4f445f-bkxtc -- /bin/bash
root@ctf-frontend-f7f4f445f-bkxtc:/app# cd frontend
root@ctf-frontend-f7f4f445f-bkxtc:/app/frontend# flask db upgrade
/usr/local/lib/python3.9/site-packages/flask_sqlalchemy/__init__.py:872: FSADeprecationWarning: SQLALCHEMY_TRACK_MODIFICATIONS adds significant overhead and will be disabled by default in the future.  Set it to True or False to suppress this warning.
  warnings.warn(FSADeprecationWarning(
/usr/local/lib/python3.9/site-packages/jose/backends/cryptography_backend.py:18: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
  from cryptography.utils import int_from_bytes, int_to_bytes
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 6e85efd406c7, Initial migrations
INFO  [alembic.runtime.migration] Running upgrade 6e85efd406c7 -> 5213f9e65a8c, Add documentation table and minor adjustments
```

If you see at least a couple of `Running upgrade` lines, the migration succeeded.

## Accessing the UI
To access the UI, we need to enable the minikube tunnel. In your WSL shell, run `minikube tunnel`.
It should be noted that you will need to have the tunnel running during any development work, it is
not a permanent operation. You should see output similar to the following, requiring your sudo
password.

```
☁  ~  minikube tunnel
❗  The service ingress-nginx-controller requires privileged ports to be exposed: [80 443]
🔑  sudo permission will be asked for it.
🏃  Starting tunnel for service ingress-nginx-controller.
[sudo] password for lgorence:
```

The UI should now be accessible from your Windows machine by navigating to https://ctf/. As this is
running locally (nor is it a valid TLD), you will not have a valid SSL certificate, and your browser
will likely require you to accept the security risk. Brave may have issues with this, not allowing
you to bypass the risk.
