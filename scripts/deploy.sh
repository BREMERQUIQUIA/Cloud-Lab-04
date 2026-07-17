#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform/environments/dev"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"
PLAN_FILE="$TERRAFORM_DIR/tfplan"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

cleanup() {
  rm -f "$PLAN_FILE"
}

on_error() {
  local exit_code=$?
  error "El despliegue falló en la línea ${BASH_LINENO[0]}."
  cleanup
  exit "$exit_code"
}

trap on_error ERR
trap cleanup EXIT

echo "=================================================="
echo " Cloud-Lab-04 - Despliegue de infraestructura"
echo "=================================================="

for command_name in terraform aws ansible-playbook; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    error "$command_name no está instalado o no está disponible en PATH."
    exit 1
  fi
done

if [[ ! -d "$TERRAFORM_DIR" ]]; then
  error "No existe el directorio Terraform: $TERRAFORM_DIR"
  exit 1
fi

if [[ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]]; then
  error "No existe terraform.tfvars."
  info "Créalo con:"
  echo "cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars"
  exit 1
fi

info "Verificando identidad AWS..."

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_ARN="$(aws sts get-caller-identity --query Arn --output text)"

echo "Cuenta AWS: $AWS_ACCOUNT_ID"
echo "Identidad:  $AWS_ARN"

info "Inicializando Terraform y el backend remoto..."

terraform -chdir="$TERRAFORM_DIR" init -reconfigure

info "Formateando archivos Terraform..."

terraform -chdir="$TERRAFORM_DIR" fmt -recursive

info "Validando configuración Terraform..."

terraform -chdir="$TERRAFORM_DIR" validate

info "Generando plan de despliegue..."

terraform -chdir="$TERRAFORM_DIR" plan \
  -out="$PLAN_FILE"

echo
warning "Revisa el plan anterior."
read -r -p "Escribe APPLY para continuar: " CONFIRMATION

if [[ "$CONFIRMATION" != "APPLY" ]]; then
  warning "Despliegue cancelado."
  exit 0
fi

info "Aplicando infraestructura..."

terraform -chdir="$TERRAFORM_DIR" apply "$PLAN_FILE"

success "Infraestructura creada."

info "Esperando disponibilidad inicial de los recursos..."

sleep 30

if [[ -f "$ANSIBLE_DIR/apply-app.yml" && -s "$ANSIBLE_DIR/apply-app.yml" ]]; then
  info "Ejecutando configuración Ansible..."
  (
    cd "$ANSIBLE_DIR"
    ansible-playbook apply-app.yml
  )
else
  warning "apply-app.yml no existe o está vacío. Se omite esta etapa."
fi

if [[ -f "$ANSIBLE_DIR/validate.yml" && -s "$ANSIBLE_DIR/validate.yml" ]]; then
  info "Ejecutando validación Ansible..."
  (
    cd "$ANSIBLE_DIR"
    ansible-playbook validate.yml
  )
else
  warning "validate.yml no existe o está vacío. Se omite esta etapa."
fi

echo
success "Despliegue completado correctamente."

echo
echo "Outputs:"
terraform -chdir="$TERRAFORM_DIR" output

echo
warning "Confirma la suscripción SNS enviada por correo, si todavía está pendiente."
warning "Recuerda destruir el laboratorio al terminar para evitar costos."
