# Internal Git and CI/CD Platform Based on GitLab

## Overview

This project implements an internal Git and CI/CD platform using **GitLab deployed on Microsoft Azure**.

The platform provides a self-hosted environment for:

* Git repository hosting
* Source control and collaboration
* Continuous Integration (CI)
* Continuous Deployment (CD)
* Automated Docker builds
* Automated application deployment

The infrastructure is provisioned using **Terraform**, while GitLab is deployed using **Docker Compose**. A GitLab Runner executes the CI/CD pipelines.


---

## Technologies

* **Microsoft Azure** – Cloud infrastructure
* **Terraform** – Infrastructure as Code
* **GitLab CE** – Self-hosted Git and CI/CD platform
* **GitLab Runner** – CI/CD job execution
* **Docker** – Containerization
* **Docker Compose** – GitLab deployment
* **Python / Flask** – Sample application
* **Git** – Source control

---

## Infrastructure

Terraform is used to provision the Azure infrastructure, including:

* Resource Group
* Virtual Network
* Subnet
* Network Security Group
* Public IP
* Network Interface
* Linux Virtual Machine
* SSH access

The VM runs Ubuntu and hosts the GitLab platform and GitLab Runner.

### Deploy infrastructure

From the Terraform directory:

```bash
terraform init
terraform plan
terraform apply
```

To remove infrastructure created by Terraform:

```bash
terraform destroy
```

---

## GitLab Deployment

GitLab CE is deployed using Docker Compose.

The GitLab container exposes:

```text
HTTP   : 80
HTTPS  : 443
SSH    : 2222
```

GitLab SSH uses port `2222` because port `22` is used for SSH access to the Azure VM.

---

## GitLab Runner

A self-hosted GitLab Runner is installed on the Azure VM.

The Runner uses the **Docker executor** and communicates with the host Docker daemon through:

```text
/var/run/docker.sock
```

This allows CI/CD jobs to build and deploy Docker containers directly on the Azure VM.

---

## CI/CD Pipeline

The sample application demonstrates a three-stage pipeline:

```text
Test
  ↓
Build
  ↓
Deploy
```

### 1. Test

The application dependencies are installed and the Flask application is imported to verify that it loads correctly.

### 2. Build

A Docker image is built:

```bash
docker build -t demo-app:latest .
```

### 3. Deploy

The existing application container is stopped and replaced with the newly built image:

```bash
docker stop demo-app || true
docker rm demo-app || true
docker run -d --name demo-app -p 5000:5000 demo-app:latest
```

Therefore, pushing a change to the GitLab repository automatically triggers:

```text
Git Push
   ↓
Pipeline
   ↓
Automated Test
   ↓
Docker Build
   ↓
Deployment
```

---

## Sample Application

The project includes a simple Flask application used to demonstrate the CI/CD workflow.

### Application endpoints

```text
GET /
```

Returns:

```text
Hello from GitLab CI/CD!
```

Health check:

```text
GET /health
```

Returns:

```json
{
  "status": "healthy"
}
```

The application listens on port `5000`.

---

## Demonstration

A typical deployment can be demonstrated by modifying the application:

```python
return "Hello from GitLab CI/CD!"
```

For example, change the message, commit the change, and push it:

```bash
git add .
git commit -m "Update application"
git push
```

GitLab automatically starts the pipeline.

After the pipeline succeeds, the updated Docker container is running on the Azure VM.

---
## Author

**Basel Alzahrani**

Software Engineering
