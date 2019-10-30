# Prometheus and Grafana on Digital Ocean

### Features
- **[Prometheus](https://prometheus.io/)**
- **[Alertmanager](https://github.com/prometheus/alertmanager)**
- **[Grafana](https://grafana.com/)**
- **[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)**
- **[node-exporter](https://github.com/prometheus/node_exporter)**

## Getting Started

- Install `kubectl` command-line interface to connect to your cluster [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version control system installed on your local machine. 
- The Coreutils [base64](https://www.gnu.org/software/coreutils/manual/html_node/base64-invocation.html) tool installed on your local machine. If you're using a Linux machine, this will most likely already be installed. If you're using OS X, you can use `openssl base64`, which comes installed by default.

To start, clone this repo on your local machine:

```shell
git clone https://github.com/mariamiah/Prometheus-Grafana-k8s-traefik.git
```

Next, move into the cloned repository:

```shell
cd Prometheus-Grafana-k8s-traefik
```
## Set up Prometheus and Grafana
Set the `APP_INSTANCE_NAME` and `NAMESPACE` environment variables.
```shell
export APP_INSTANCE_NAME=monitoring-cluster
export NAMESPACE=default
```

Use the `base64` command to base64-encode a secure Grafana password of your choosing:

```shell
export GRAFANA_GENERATED_PASSWORD="$(echo -n 'your_grafana_password' | base64)"
```

Now, use `awk` and `envsubst` to fill in the `APP_INSTANCE_NAME`, `NAMESPACE`, and `GRAFANA_GENERATED_PASSWORD` variables in the repo's manifest files. After substituting in the variable values, the files will be combined into a master manifest file called `$APP_INSTANCE_NAME_manifest.yaml`.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* \
 | envsubst '$APP_INSTANCE_NAME $NAMESPACE $GRAFANA_GENERATED_PASSWORD' \
 > "${APP_INSTANCE_NAME}_manifest.yaml"
```

Now, use `kubectl apply -f` to apply the manifest and create the stack in the Namespace you configured:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

You can use `kubectl get all` to monitor deployment status.

## Viewing the Grafana Dashboards

Once the stack is up and running, you can access Grafana by either patching the Grafana ClusterIP Service to create a DigitalOcean Load Balancer, or by forwarding a local port. 

### Exposing the Grafana Service using a Load Balancer

To create a LoadBalancer Service for Grafana, use `kubectl patch` to update the existing Grafana Service in-place:

```shell
kubectl patch svc "$APP_INSTANCE_NAME-grafana" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

Once the DigitalOcean Load Balancer has been created and assigned an external IP address, you can fetch this external IP using the following commands:

```shell
SERVICE_IP=$(kubectl get svc $APP_INSTANCE_NAME-grafana \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}/"
```

### Forwarding a Local Port to Access the Grafana Service

If you don't want to expose the Grafana Service externally, you can also forward local port 3000 into the cluster using `kubectl port-forward`. To learn more about forwarding ports into a Kubernetes cluster, consult [Use Port Forwarding to Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

```shell
kubectl port-forward --namespace ${NAMESPACE} ${APP_INSTANCE_NAME}-grafana-0 3000
```

You can now access the Grafana UI locally at `http://localhost:3000/`.

## Set up Traefik ingress controller
- Set up the traefik manifest
```shell
awk 'FNR==1 {print "---"}{print}' traefik/* > "traefik_manifest.yaml"
```
- Apply the manifest
```shell
kubectl apply -f "traefik_manifest.yaml" --namespace "${NAMESPACE}"
```

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