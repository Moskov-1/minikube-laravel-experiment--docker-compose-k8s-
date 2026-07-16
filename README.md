# Laravel + MySQL on Kubernetes (Minikube)

A simple Laravel application deployed on Kubernetes using Minikube, backed by a MySQL database. This project demonstrates containerization, Kubernetes Deployments, Services, Secrets, scaling, and local development workflows without requiring Docker Hub.

---

# Architecture

```text
                    ┌─────────────────────┐
                    │   Laravel Service   │
                    │   LoadBalancer      │
                    └──────────┬──────────┘
                               │
                               ▼
            ┌───────────────────────────────────┐
            │ Laravel Deployment (3 Replicas)   │
            ├───────────────────────────────────┤
            │ Laravel Pod #1                    │
            │ Laravel Pod #2                    │
            │ Laravel Pod #3                    │
            └───────────────────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   MySQL Service     │
                    │   ClusterIP         │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ MySQL Deployment    │
                    │ 1 Replica           │
                    └─────────────────────┘
```

---

# Prerequisites

- Docker Desktop
- Minikube
- kubectl
- Laravel Application
- Dockerfile for Laravel

Verify installation:

```bash
docker --version
minikube version
kubectl version --client
```

---

# Start Minikube

```bash
minikube start
```

Verify cluster status:

```bash
minikube status
```

Expected output:

```text
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

---

# Build Application Image

Build the Laravel image locally:

```bash
docker build -t laravel-app:latest .
```

Load the image into Minikube:

```bash
minikube image load laravel-app:latest
```

Verify:

```bash
minikube image ls
```

---

# Create Kubernetes Secret

Create a dedicated environment file:

```env
APP_NAME=Laravel
APP_ENV=local
APP_DEBUG=true

DB_CONNECTION=mysql
DB_HOST=mysql-service
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root

APP_KEY=base64:your-key
```

Create the secret:

```bash
kubectl create secret generic laravel-secrets \
  --from-env-file=.env.minikube
```

Verify:

```bash
kubectl get secret
kubectl describe secret laravel-secrets
```

---

# Deployment Configuration

The Laravel Deployment loads environment variables from the secret:

```yaml
envFrom:
    - secretRef:
          name: laravel-secrets
```

MySQL runs as a separate Deployment and is exposed internally through a ClusterIP Service.

---

# Deploy Application

Apply all resources:

```bash
kubectl apply -f k8s.yml
```

Verify Deployments:

```bash
kubectl get deploy
```

Verify Pods:

```bash
kubectl get pods
```

Expected:

```text
laravel-app-xxxxx            Running
laravel-app-yyyyy            Running
laravel-app-zzzzz            Running
mysql-deployment-xxxxx       Running
```

Verify Services:

```bash
kubectl get svc
```

---

# Access the Application

Open the Laravel service:

```bash
minikube service laravel-service
```

This automatically opens the application in the browser.

---

# Database Migrations and Seeders

Find a Laravel pod:

```bash
kubectl get pods
```

Execute migrations:

```bash
kubectl exec -it <laravel-pod> -- php artisan migrate
```

Run seeders:

```bash
kubectl exec -it <laravel-pod> -- php artisan db:seed
```

Or run both:

```bash
kubectl exec -it <laravel-pod> -- php artisan migrate --seed
```

---

# Updating Secrets

After modifying `.env.minikube`:

```bash
kubectl create secret generic laravel-secrets \
  --from-env-file=.env.minikube \
  --dry-run=client -o yaml | kubectl apply -f -
```

Restart the deployment:

```bash
kubectl rollout restart deployment laravel-app
```

Wait for rollout:

```bash
kubectl rollout status deployment/laravel-app
```

---

# Scaling Laravel

Increase replicas:

```bash
kubectl scale deployment laravel-app --replicas=5
```

Verify:

```bash
kubectl get pods
```

Reduce replicas:

```bash
kubectl scale deployment laravel-app --replicas=1
```

---

# Useful Commands

## View Pods

```bash
kubectl get pods
```

## View Deployments

```bash
kubectl get deploy
```

## View Services

```bash
kubectl get svc
```

## View Logs

```bash
kubectl logs <pod-name>
```

## Execute Into Container

```bash
kubectl exec -it <pod-name> -- sh
```

## Describe Resource

```bash
kubectl describe pod <pod-name>
```

---

# Stop Minikube

Stop the cluster while preserving state:

```bash
minikube stop
```

Start again later:

```bash
minikube start
```

---

# Delete Minikube Cluster

Remove everything:

```bash
minikube delete
```

---

# Concepts Learned

- Docker image creation
- Local image loading into Minikube
- Kubernetes Deployments
- Kubernetes Services
- ClusterIP vs LoadBalancer
- Environment variables
- Kubernetes Secrets
- Rolling updates
- Scaling replicas
- Laravel container deployment
- MySQL service discovery
- Running migrations and seeders inside containers
- Basic Kubernetes troubleshooting
