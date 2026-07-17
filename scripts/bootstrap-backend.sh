#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$PROJECT_ROOT/bootstrap"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

trap 'error "El script falló en la línea ${LINENO}."; exit 1' ERR

echo "=================================================="
echo " Cloud-Lab-04 - Bootstrap Backend"
echo "=================================================="

command -v terraform >/dev/null || {
    error "Terraform no está instalado."
    exit 1
}

command -v aws >/dev/null || {
    error "AWS CLI no está instalado."
    exit 1
}

info "Verificando identidad AWS..."

aws sts get-caller-identity

if [[ ! -f "$BOOTSTRAP_DIR/terraform.tfvars" ]]; then
    error "No existe bootstrap/terraform.tfvars"
    echo
    echo "Ejecuta:"
    echo
    echo "cd bootstrap"
    echo "cp terraform.tfvars.example terraform.tfvars"
    exit 1
fi

cd "$BOOTSTRAP_DIR"

info "Inicializando Terraform..."

terraform init

info "Validando configuración..."

terraform fmt -check
terraform validate

info "Creando backend remoto..."

terraform apply -auto-approve

echo
success "Bootstrap completado."

echo
echo "Bucket:"
terraform output terraform_state_bucket

echo
echo "Región:"
terraform output aws_region

echo
success "Backend remoto listo."
