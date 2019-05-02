# Environment

## Set up devops environment

### Install Ubuntu 18.04 as a Windows Sub-system for Linux
Windows Subsystem for Linux (WSL) is a compatibility layer for running Linux binary executables (in ELF format) natively on Windows 10 and Windows Server 2019.
Before installing a Linux distro for WSL, you must ensure that the "Windows Subsystem for Linux" optional feature is enabled

- Open PowerShell as Administrator and run:

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

*If enabling WSL requires developer mode, then open Settings -> click on Update & security -> click on For Developers. Under "Use developer features", select the Developer mode option to setup the environment to install Bash.

- Restart your computer when prompted

- Download and install your Ubuntu 18.04 LTS distro from Microsoft Store

- Complete initialization of your distro
Start "Bash on Ubuntu on Windows" from Start menu. Ubuntu installation should finish and you'll see in bash "Installing, this may take a few minutes..."

- You will be asked to create a new UNIX user. 
- Create a new user/pass - acme:changeit
- Success - acme@LUMEE-NB49:~$

### Configure your Ubuntu installation

[Optional] If ~/.bash_profile does not exist

    cp /etc/skel/.profile ~/.bash_profile

Append your username to a file at ~/.acmerc

    export LUM_USERNAME="c00011" # Use your own PC username

Append to ~/.bashrc  

    if [ -f ~/.acmerc ]; then
        . ~/.acmerc
    fi
    
Clone binaries' repository
    
    sudo git clone https://github.com/studiofrancium/k8s-linux-amd64-bin.git /opt/k8s-linux-amd64-bin
    
Create symlink    
    
    sudo ln -s /opt/k8s-linux-amd64-bin /opt/k8s
    
Append to ~/.bash_profile

    export KUBERNETES_HOME="/opt/k8s"
    PATH=$KUBERNETES_HOME/bin:$PATH
 
### Self-signed keystore & truststore

    git clone https://github.com/studiofrancium/franciumca.git /opt/franciumca    

Create symlink    
    
    sudo ln -s /opt/franciumca/tls/keystore /opt/keystore

### Acme devops scripts

Create symlink    
    
    sudo ln -s /mnt/c/icecode/techex/acme-devops/acmekube /opt/acmekube

## Generate JHipster stand-alone web application

https://www.jhipster.tech/2019/04/04/jhipster-release-6.0.0-beta.0.html

Generate webapp:

    jhipster

Generate helm chart:

    jhipster kubernetes-helm

## Build Docker image & push

Build:

    ./mvnw -Pprod verify jib:dockerBuild

Tag & push:

    docker login -u "studiofrancium" -p "Z8n78Lk5QNC8df" docker.io
    docker image tag latest studiofrancium/acme-web
    docker push studiofrancium/acme-web:latest
    

## Working with minikube
### Setting up the environment

#### Install required third-party software for running minikube
1. Install Virtualbox for Windows 10 [https://www.virtualbox.org/wiki/Downloads] 
2. Install Minikube.exe from GitHub releases [https://github.com/kubernetes/minikube/releases]

#### Start Minikube cluster in WSL
Start minikube. Type in PowerShell:

    minikube start --cpus=2 --memory=8192 --disk-size=14g --vm-driver=virtualbox --bootstrapper=kubeadm --v=2
    minikube ssh sudo ip link set docker0 promisc on
    minikube addons enable ingress

#### Create Kubernetes configuration file in Ubuntu
Append Minikube home to .acmerc

    export LUM_MINIKUBE_HOME="/mnt/c/Users/$LUM_USERNAME/.minikube"

then
    
    source /home/acme/.bash_profile
    ln -s $LUM_MINIKUBE_HOME /home/acme/.minikube
    
Append minikube host to /etc/hosts file

    192.168.99.100  kubernetes.default
    192.168.99.100	m1kube-acme.example.com

Link local Kube config to Minikube cluster

    kubectl config set-cluster minikube \
     --server=https://kubernetes.default:8443 \
     --certificate-authority=$LUM_MINIKUBE_HOME/ca.crt
     
    kubectl config set-credentials minikube \
     --client-certificate=$LUM_MINIKUBE_HOME/client.crt \
     --client-key=$LUM_MINIKUBE_HOME/client.key
     
    kubectl config set-context minikube --cluster=minikube --user=minikube
     
    kubectx minikube

### Test Minikube

Show namespace and running pods

    kubectl get pods --all-namespaces

*Pods will take up to 10 minutes to start up.

You can test the VM as so:

    curl --insecure https://kubernetes.default:8443

then
    
    ssh -i %LUM_MINIKUBE_HOME%\.minikube\machines\minikube\id_rsa docker@minikube.local

Go to minikube dashboard and wait for pods to finish startup. Type in PowerShell:

    minikube dashboard

[http://minikube.local:30000/]

### Stop & delete
Stopping minikube cluster. Type in PowerShell:

    minikube stop

Deleting minikube cluster. Type in PowerShell:

    minikube delete

*To completely remove all configuration you need  to delete rm -Rf ~/.kube/ ~/.minikube/ ~/.helm/

# Using the /opt/acmeops/**/*.sh scripts

## Helm install

### Deploy ACME to a K8s cluster
In order to deploy ACME you need to have set up access to a K8S cluster such as Minikube. 

Test your access to m1kube:

    kubectx minikube

[Optional] Deploy Ingress controller (not required for minikube)

    /opt/acmekube/bin/ci/ingress.sh

Create new namespace for acme

    /opt/acmekube/bin/ns/ns-create.sh

Switch to namespace:

    /opt/acmekube/bin/ctx/m1kube-acme.sh

Deploy helm chart for PostgreSQL

    /opt/forgekube/bin/ci/postgresql.sh

Deploy helm chart for ACME

    /opt/acmekube/bin/ci/acme.sh

Then go to: [https://m1kube-acme.example.com/]

Tail ACME

    /opt/acmekube/bin/tail/openam.sh

### Debug ACME pod

    /opt/acmekube/bin/port-forward/acme/5005.sh

Then configure & run debug config in IntelliJ against localhost:5005 port.

### Remove pods

    helm delete --purge acme
    helm delete --purge postgresql


# Troubleshooting

Minikube helpers

    minikube ip # get cluster IP address
    minikube ssh # get cluster cli

How to Reinstall the Ubuntu Environment

    lxrun /install
