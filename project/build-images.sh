#!/usr/bin/env bash
# Baut alle Images der Hello-App aus den Beispielständen neu.
# Nutzen: wenn Images fehlen (z. B. nach "Reset Kubernetes Cluster" oder auf einem neuen Rechner).
# Aufruf aus dem Ordner project/:  bash build-images.sh
set -euo pipefail
cd "$(dirname "$0")"

APP=playground                                   # Quellcode der App (app.py, requirements.txt)
D1=examples/m01-containers/l03-images            # Dockerfiles aus Lab 1.3
D2=examples/m10-security/l03-pod-security        # Dockerfiles ohne root aus Lab 10.3

docker build -t hello-backend:v1          -f $D1/backend/Dockerfile     $APP/backend
docker build -t hello-frontend:v1         -f $D1/frontend/Dockerfile    $APP/frontend
docker build -t hello-frontend:v2         -f $D1/frontend/Dockerfile.v2 $APP/frontend
docker build -t hello-backend:v1-nonroot  -f $D2/backend/Dockerfile     $APP/backend
docker build -t hello-frontend:v1-nonroot -f $D2/frontend/Dockerfile    $APP/frontend
docker build -t hello-frontend:v2-nonroot -f $D2/frontend/Dockerfile.v2 $APP/frontend

docker images --filter "reference=hello-*"
