#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform/environments/dev"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

on_error() {
  local exit_code=$?
  error "La validación falló en la línea ${BASH_LINENO[0]}."
  exit "$exit_code"
}

trap on_error ERR

echo "=================================================="
echo " Cloud-Lab-04 - Validación de infraestructura"
echo "=================================================="

for command_name in terraform aws ansible-playbook curl jq; do
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
  error "No existe terraform.tfvars en $TERRAFORM_DIR"
  exit 1
fi

info "Verificando identidad AWS..."

aws sts get-caller-identity >/dev/null
success "Identidad AWS validada."

info "Inicializando Terraform y el backend remoto..."

terraform -chdir="$TERRAFORM_DIR" init -reconfigure >/dev/null

info "Comprobando formato Terraform..."

terraform -chdir="$TERRAFORM_DIR" fmt -check -recursive

info "Validando configuración Terraform..."

terraform -chdir="$TERRAFORM_DIR" validate

info "Comprobando diferencias entre código e infraestructura..."

set +e
terraform -chdir="$TERRAFORM_DIR" plan -detailed-exitcode
PLAN_EXIT_CODE=$?
set -e

case "$PLAN_EXIT_CODE" in
  0)
    success "Terraform no detectó cambios."
    ;;
  1)
    error "Terraform plan terminó con error."
    exit 1
    ;;
  2)
    error "Terraform detectó cambios pendientes o drift."
    exit 2
    ;;
  *)
    error "Código de salida inesperado de Terraform: $PLAN_EXIT_CODE"
    exit "$PLAN_EXIT_CODE"
    ;;
esac

info "Leyendo outputs Terraform..."

ALB_DNS_NAME="$(terraform -chdir="$TERRAFORM_DIR" output -raw alb_dns_name)"
ASG_NAME="$(terraform -chdir="$TERRAFORM_DIR" output -raw autoscaling_group_name)"
TARGET_GROUP_ARN="$(terraform -chdir="$TERRAFORM_DIR" output -raw target_group_arn)"
DB_ADDRESS="$(terraform -chdir="$TERRAFORM_DIR" output -raw db_address)"
SNS_TOPIC_ARN="$(terraform -chdir="$TERRAFORM_DIR" output -raw sns_topic_arn)"
DASHBOARD_NAME="$(terraform -chdir="$TERRAFORM_DIR" output -raw cloudwatch_dashboard_name)"

info "Validando respuesta HTTP del ALB..."

ALB_RESPONSE="$(curl --fail --silent --show-error --max-time 10 "http://$ALB_DNS_NAME")"

if [[ "$ALB_RESPONSE" != *"Cloud-Lab-04 Auto Scaling Application"* ]]; then
  error "El ALB respondió, pero el contenido no es el esperado."
  exit 1
fi

success "ALB responde correctamente."

info "Obteniendo instancias actuales del Auto Scaling Group..."

INSTANCE_IDS_JSON="$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --region us-east-1 \
  --query "AutoScalingGroups[0].Instances[?LifecycleState=='InService' && HealthStatus=='Healthy'].InstanceId" \
  --output json)"

INSTANCE_COUNT="$(jq 'length' <<<"$INSTANCE_IDS_JSON")"

if (( INSTANCE_COUNT < 2 )); then
  error "El Auto Scaling Group tiene menos de dos instancias Healthy/InService."
  echo "$INSTANCE_IDS_JSON"
  exit 1
fi

success "Auto Scaling Group con $INSTANCE_COUNT instancias Healthy/InService."

mapfile -t INSTANCE_IDS < <(jq -r '.[]' <<<"$INSTANCE_IDS_JSON")

info "Validando targets del ALB..."

TARGET_HEALTH_JSON="$(aws elbv2 describe-target-health \
  --target-group-arn "$TARGET_GROUP_ARN" \
  --region us-east-1 \
  --query "TargetHealthDescriptions[*].TargetHealth.State" \
  --output json)"

UNHEALTHY_TARGETS="$(jq '[.[] | select(. != "healthy")] | length' <<<"$TARGET_HEALTH_JSON")"

if (( UNHEALTHY_TARGETS > 0 )); then
  error "Existen targets no saludables en el Target Group."
  echo "$TARGET_HEALTH_JSON"
  exit 1
fi

success "Todos los targets del ALB están healthy."

info "Validando Systems Manager..."

for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
  PING_STATUS="$(aws ssm describe-instance-information \
    --region us-east-1 \
    --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
    --query "InstanceInformationList[0].PingStatus" \
    --output text)"

  if [[ "$PING_STATUS" != "Online" ]]; then
    error "$INSTANCE_ID no está Online en Systems Manager."
    exit 1
  fi

  success "$INSTANCE_ID está Online en SSM."
done

info "Validando conectividad EC2 hacia RDS por TCP 3306..."

for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
  COMMAND_ID="$(aws ssm send-command \
    --region us-east-1 \
    --document-name "AWS-RunShellScript" \
    --instance-ids "$INSTANCE_ID" \
    --parameters "commands=[\"timeout 5 bash -c '</dev/tcp/$DB_ADDRESS/3306'\"]" \
    --query "Command.CommandId" \
    --output text)"

  aws ssm wait command-executed \
    --region us-east-1 \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID"

  COMMAND_STATUS="$(aws ssm get-command-invocation \
    --region us-east-1 \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --query "Status" \
    --output text)"

  if [[ "$COMMAND_STATUS" != "Success" ]]; then
    error "Falló la conectividad $INSTANCE_ID → $DB_ADDRESS:3306"
    exit 1
  fi

  success "$INSTANCE_ID puede conectarse a RDS por TCP 3306."
done

info "Validando suscripción SNS..."

SUBSCRIPTION_STATUS="$(aws sns list-subscriptions-by-topic \
  --topic-arn "$SNS_TOPIC_ARN" \
  --region us-east-1 \
  --query "Subscriptions[0].SubscriptionArn" \
  --output text)"

if [[ "$SUBSCRIPTION_STATUS" == "PendingConfirmation" || "$SUBSCRIPTION_STATUS" == "None" ]]; then
  warning "La suscripción SNS todavía está pendiente de confirmación."
else
  success "Suscripción SNS confirmada."
fi

info "Validando dashboard de CloudWatch..."

aws cloudwatch get-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --region us-east-1 \
  >/dev/null

success "Dashboard de CloudWatch disponible."

info "Validando alarmas de CloudWatch..."

ALARM_COUNT="$(aws cloudwatch describe-alarms \
  --alarm-name-prefix "cloud-lab-04-dev" \
  --region us-east-1 \
  --query "length(MetricAlarms)" \
  --output text)"

if (( ALARM_COUNT < 2 )); then
  error "Se esperaban al menos dos alarmas CloudWatch."
  exit 1
fi

success "CloudWatch tiene $ALARM_COUNT alarmas configuradas."

if [[ -f "$ANSIBLE_DIR/validate.yml" && -s "$ANSIBLE_DIR/validate.yml" ]]; then
  info "Ejecutando validación Ansible..."

  (
    cd "$ANSIBLE_DIR"
    ansible-playbook validate.yml
  )
else
  warning "ansible/validate.yml no existe o está vacío. Se omite."
fi

echo
success "CLOUD-LAB-04 INFRASTRUCTURE VALIDATION SUCCESSFUL"
