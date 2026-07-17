#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform/environments/dev"
PLAN_FILE="$TERRAFORM_DIR/destroy.tfplan"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

cleanup() {
  rm -f "$PLAN_FILE"
}

on_error() {
  local exit_code=$?
  log_error "La destrucción falló en la línea ${BASH_LINENO[0]}."
  cleanup
  exit "$exit_code"
}

trap on_error ERR
trap cleanup EXIT

echo "=================================================="
echo " Cloud-Lab-04 - Destrucción de infraestructura"
echo "=================================================="

if ! command -v terraform >/dev/null 2>&1; then
  log_error "Terraform no está instalado o no está disponible en PATH."
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  log_error "AWS CLI no está instalado o no está disponible en PATH."
  exit 1
fi

if [[ ! -d "$TERRAFORM_DIR" ]]; then
  log_error "No existe el directorio Terraform: $TERRAFORM_DIR"
  exit 1
fi

if [[ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]]; then
  log_error "No existe terraform.tfvars en $TERRAFORM_DIR"
  log_info "Créalo con:"
  echo "cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars"
  exit 1
fi

log_info "Verificando identidad AWS..."

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_ARN="$(aws sts get-caller-identity --query Arn --output text)"

echo "Cuenta AWS: $AWS_ACCOUNT_ID"
echo "Identidad:  $AWS_ARN"

log_warning "Este proceso eliminará los recursos del ambiente dev."
echo
read -r -p "Escribe DESTROY para continuar: " CONFIRMATION

if [[ "$CONFIRMATION" != "DESTROY" ]]; then
  log_warning "Operación cancelada."
  exit 0
fi

log_info "Inicializando Terraform y el backend remoto..."

terraform -chdir="$TERRAFORM_DIR" init -reconfigure

log_info "Validando la configuración Terraform..."

terraform -chdir="$TERRAFORM_DIR" validate

log_info "Generando plan de destrucción..."

terraform -chdir="$TERRAFORM_DIR" plan \
  -destroy \
  -out="$PLAN_FILE"

echo
log_warning "Revisa el plan anterior antes de continuar."
read -r -p "Escribe YES para aplicar el plan de destrucción: " FINAL_CONFIRMATION

if [[ "$FINAL_CONFIRMATION" != "YES" ]]; then
  log_warning "Destrucción cancelada."
  exit 0
fi

log_info "Destruyendo infraestructura..."

terraform -chdir="$TERRAFORM_DIR" apply "$PLAN_FILE"

log_info "Comprobando el estado remoto..."

STATE_RESOURCES="$(terraform -chdir="$TERRAFORM_DIR" state list 2>/dev/null || true)"

if [[ -n "$STATE_RESOURCES" ]]; then
  log_error "Todavía quedan recursos en el estado:"
  echo "$STATE_RESOURCES"
  exit 1
fi

log_success "La infraestructura del ambiente dev fue destruida."
log_success "El estado Terraform no contiene recursos."

echo
echo "El bucket S3 del bootstrap se conserva intencionalmente."
echo "No ejecutes terraform destroy dentro de bootstrap."
