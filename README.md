# Patidosa — Dosa Batter Shop (Java / Spring Boot + Kubernetes)

A Spring Boot web app for the Pati Dosa Batter shop, built for a Java-based
DevOps pipeline: **Maven build -> Docker -> Kubernetes**, with a GitHub
Actions CI/CD pipeline that builds, pushes, and applies the K8s manifests
automatically.

## Architecture
```
GitHub push (main)
      |
      v
GitHub Actions
  1. mvn package (inside Docker multi-stage build)
  2. Push image to Docker Hub
  3. kubectl apply -f k8s/  (rolling update on your cluster)
      |
      v
Kubernetes cluster
  Service (LoadBalancer, port 80) --> Deployment (2 pods, port 8080, Spring Boot app)
```

## Pages & endpoints
- `/` — the shop page: 1/2 kg (Rs 60) and 1 kg (Rs 110) dosa batter, Add to
  cart buttons, and a popup cart with quantity controls and a running total
- `/actuator/health` — Spring Boot Actuator health check (used by K8s probes & Docker HEALTHCHECK)
- `/api/info` — hostname, version, uptime (useful for confirming which pod served a request)

Prices and product names are set in `src/main/resources/static/index.html`,
inside the `products` array in the `<script>` tag.

## 1. Build & run locally
```bash
mvn clean package
java -jar target/patidosa.jar
# visit http://localhost:8080
```

Or with Docker:
```bash
docker build -t patidosa .
docker run -p 8080:8080 patidosa
```

## 2. Push the image manually (without CI/CD)
```bash
docker build -t <dockerhub-user>/patidosa:latest .
docker push <dockerhub-user>/patidosa:latest
```

## 3. Deploy to Kubernetes
Edit `k8s/deployment.yaml` and replace:
```
image: <dockerhub-username>/patidosa:latest
```
with your actual Docker Hub image, then:
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get svc patidosa-service   # note the EXTERNAL-IP once assigned
```

No cluster yet? Options for a quick demo cluster:
- **Minikube** (local): `minikube start`, then `minikube service patidosa-service`
- **AWS EKS** (cloud, closer to real production setups)
- **kind** (Kubernetes-in-Docker, fast local option)

## 4. GitHub Actions CI/CD (optional, automatic deploys)
Add these **Repository Secrets** in GitHub (Settings -> Secrets and variables -> Actions):

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | A Docker Hub access token |
| `KUBE_CONFIG` | Your kubeconfig file, base64-encoded: `cat ~/.kube/config \| base64 -w 0` |

Push to `main` -> the workflow builds the image, pushes it, and runs
`kubectl apply` against your cluster automatically.

## Project structure
```
patidosa/
├── pom.xml                                 # Maven build file
├── src/main/java/.../PatidosaApplication.java
├── src/main/java/.../controller/InfoController.java
├── src/main/resources/application.properties
├── src/main/resources/static/index.html    # the shop page (products + cart)
├── Dockerfile                              # multi-stage Maven build, non-root, HEALTHCHECK
├── .dockerignore
├── k8s/
│   ├── deployment.yaml                     # 2 replicas, readiness/liveness probes
│   └── service.yaml                        # LoadBalancer service, port 80 -> 8080
└── .github/workflows/deploy.yml            # CI/CD: build, push, kubectl apply
```

## Ideas to extend this demo further
- Wire the cart's Checkout button to a real order/payments API
- Add a Helm chart instead of raw manifests
- Add a `HorizontalPodAutoscaler` for auto-scaling
- Add an Ingress + TLS instead of a LoadBalancer Service
- Add a database for real order/inventory tracking
