## Set up Cert Manager
Cert manager helps generate an ssl certificate with [let's encrypt](https://letsencrypt.org/getting-started/)
 ```shell
export HOST=hostname

export SECRETNAME=kubernetes secret to hold the generated certificate
```

- Install Cert Manager
```shell
kubectl create namespace cert-manager
```
- Install the CustomResourceDefinitions and cert-manager itself
```shell
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml
```
- Create a cluster issuer
```
kubectl apply -f cert-manager/letsencrypt-production.yaml
```