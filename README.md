# Cloud-Lab-04

## Infraestructura AWS de nivel empresarial con Terraform, Auto Scaling, RDS, ALB, CloudWatch y Ansible

Cloud-Lab-04 es un proyecto de Infraestructura como Código (Infrastructure as Code - IaC) desarrollado en Amazon Web Services (AWS), utilizando Terraform y Ansible.

El objetivo de este laboratorio es implementar y simular una arquitectura de aplicación web de alta disponibilidad, siguiendo principios y buenas prácticas del AWS Well-Architected Framework.

El proyecto permite aprovisionar automáticamente la infraestructura, administrar sus componentes y validar su funcionamiento mediante pruebas de despliegue, operación, monitoreo, escalabilidad y recuperación ante fallos.

---

## Arquitectura

La infraestructura implementada incluye:

- Amazon VPC.
- Subredes públicas y privadas distribuidas en dos zonas de disponibilidad.
- Internet Gateway.
- NAT Gateway.
- Application Load Balancer (ALB).
- Auto Scaling Group (ASG).
- Launch Template.
- Amazon EC2.
- Amazon RDS MySQL.
- Amazon S3.
- Roles y perfiles de IAM.
- AWS Systems Manager.
- CloudWatch Dashboard.
- CloudWatch Alarms.
- Amazon SNS.
- Backend remoto de Terraform almacenado en Amazon S3.

---

## Estructura del repositorio

```text
Cloud-Lab-04
│
├── ansible/
│
├── bootstrap/
│
├── docs/
│
├── scripts/
│
└── terraform/
    │
    ├── environments/
    │   └── dev/
    │
    └── modules/
        ├── vpc/
        ├── security/
        ├── alb/
        ├── launch-template/
        ├── autoscaling/
        ├── rds/
        ├── monitoring/
        ├── sns/
        └── storage/
```

---

## Tecnologías utilizadas

| Tecnología | Propósito |
|---|---|
| Terraform | Aprovisionamiento de infraestructura como código |
| AWS CLI | Administración de servicios AWS |
| Ansible | Automatización y configuración de servidores |
| Amazon VPC | Red virtual privada |
| Amazon EC2 | Instancias de procesamiento |
| Auto Scaling | Escalamiento automático |
| Application Load Balancer | Distribución del tráfico |
| Amazon RDS MySQL | Base de datos relacional |
| Amazon S3 | Almacenamiento y backend remoto |
| Amazon CloudWatch | Monitoreo y alarmas |
| Amazon SNS | Notificaciones |
| AWS Systems Manager | Administración de instancias |
| IAM | Administración de identidades y permisos |
| Linux | Sistema operativo de los servidores |
| Bash | Automatización mediante scripts |

---

## Características principales

- Arquitectura modular utilizando Terraform.
- Backend remoto para el estado de Terraform mediante Amazon S3.
- Arquitectura de red distribuida en dos zonas de disponibilidad.
- Segmentación de redes públicas y privadas.
- NAT Gateway para conectividad saliente.
- Balanceo de carga mediante Application Load Balancer.
- Escalamiento automático de instancias EC2.
- Base de datos MySQL en una red privada.
- Almacenamiento mediante Amazon S3.
- Monitoreo y alarmas con CloudWatch.
- Notificaciones mediante Amazon SNS.
- Administración de instancias mediante Systems Manager.
- Automatización con scripts Bash.
- Configuración de servidores mediante Ansible.
- Validación de infraestructura.
- Configuración de snapshot final para Amazon RDS.

---

## Diagrama de infraestructura

```text
                         INTERNET
                            |
                            |
                    INTERNET GATEWAY
                            |
                            |
                 +----------------------+
                 | APPLICATION LOAD     |
                 | BALANCER (ALB)       |
                 +----------+-----------+
                            |
                  +---------+---------+
                  |                   |
                  |                   |
           SUBRED PRIVADA A    SUBRED PRIVADA B
                  |                   |
                  |                   |
             +---------+         +---------+
             |  EC2 #1 |         |  EC2 #2 |
             +---------+         +---------+
                  |                   |
                  +---------+---------+
                            |
                            |
                   +----------------+
                   | AMAZON RDS     |
                   | MYSQL          |
                   | RED PRIVADA    |
                   +----------------+


              SERVICIOS COMPLEMENTARIOS AWS
              ==============================

              +-----------------------------+
              | AMAZON S3                   |
              |                             |
              | - Terraform Remote Backend |
              | - Terraform State           |
              | - Storage del laboratorio  |
              +-----------------------------+

              +-----------------------------+
              | AMAZON CLOUDWATCH           |
              |                             |
              | - Dashboard                 |
              | - Métricas                  |
              | - Alarmas                   |
              +-----------------------------+

              +-----------------------------+
              | AMAZON SNS                  |
              |                             |
              | - Notificaciones            |
              +-----------------------------+

              +-----------------------------+
              | AWS SYSTEMS MANAGER          |
              |                             |
              | - Administración EC2        |
              | - Session Manager           |
              | - Ejecución de comandos      |
              +-----------------------------+

              +-----------------------------+
              | AWS IAM                     |
              |                             |
              | - Roles                     |
              | - Instance Profiles         |
              | - Permisos                  |
              +-----------------------------+
```

### Componentes de Amazon S3

El proyecto utiliza dos buckets con propósitos diferentes:

**1. Terraform Remote Backend**

Almacena el estado remoto de Terraform (`terraform.tfstate`), permitiendo mantener la información de los recursos administrados por Terraform.

Este bucket se conservó después de destruir la infraestructura principal.

**2. Storage del laboratorio**

Corresponde al módulo de almacenamiento S3 creado mediante Terraform.

Incluye configuraciones de:

- Bloqueo de acceso público.
- Versionamiento.
- Cifrado SSE-S3 (AES256).
- Reglas de ciclo de vida para versiones anteriores.

Este bucket formó parte de los 51 recursos destruidos al finalizar el laboratorio.

---

## Despliegue de infraestructura

### 1. Inicialización del backend remoto

```bash
./scripts/bootstrap-backend.sh
```

Este proceso permite preparar el almacenamiento remoto de Terraform en Amazon S3.

### 2. Despliegue de infraestructura

```bash
./scripts/deploy.sh
```

Ejecuta el proceso de inicialización, planificación y despliegue de los recursos definidos mediante Terraform.

### 3. Validación de infraestructura

```bash
./scripts/validate.sh
```

Permite comprobar el funcionamiento de los componentes desplegados.

### 4. Destrucción de infraestructura

```bash
./scripts/destroy.sh
```

Permite eliminar los recursos administrados por Terraform después de completar las pruebas.

**Importante:** el backend remoto de Terraform se mantiene separado de los recursos principales del laboratorio.

---

## Validación y pruebas realizadas

El laboratorio fue desplegado y validado mediante pruebas operativas, monitoreo y resiliencia.

### 1. Despliegue de infraestructura

Se realizaron las siguientes validaciones:

- Aprovisionamiento de infraestructura mediante módulos Terraform.
- Ejecución de automatización con Ansible.
- Validación de conectividad HTTP mediante Application Load Balancer.
- Acceso a instancias EC2 mediante AWS Systems Manager.
- Validación de conectividad de red hacia Amazon RDS.
- Verificación de componentes de monitoreo.

**Resultado:** despliegue y validaciones operativas satisfactorias.

### 2. Prueba de balanceo de carga

Se enviaron solicitudes HTTP mediante el Application Load Balancer.

**Resultados:**

- El tráfico fue distribuido entre diferentes instancias EC2.
- Se validó la participación de las dos zonas de disponibilidad.
- Se comprobó la respuesta de la aplicación a través del balanceador.

### 3. Prueba de Auto Scaling

Se generó una carga de trabajo sobre la CPU utilizando `stress-ng`, ejecutado mediante AWS Systems Manager.

**Configuración de la prueba:**

| Parámetro | Valor |
|---|---|
| Herramienta | stress-ng |
| Utilización de CPU objetivo | Aproximadamente 90 % |
| Duración | 300 segundos |
| Capacidad inicial deseada | 2 instancias |

**Resultados observados:**

- Auto Scaling incrementó la capacidad deseada de 2 a 3 instancias.
- Después de reducir la carga de trabajo, el grupo Auto Scaling disminuyó nuevamente de 3 a 2 instancias.
- Se comprobó el funcionamiento del escalamiento horizontal.

### 4. Prueba de recuperación de instancias EC2

Se simuló una instancia no saludable mediante un fallo en la verificación de estado (Health Check).

**Resultados:**

- Auto Scaling Group detectó la instancia no saludable.
- La instancia afectada fue reemplazada automáticamente.
- Se validó el mecanismo de recuperación automática.

### 5. Monitoreo con CloudWatch

Se validaron las alarmas de CloudWatch durante las pruebas de carga.

**Resultados:**

- El estado de la alarma cambió a `ALARM` cuando se alcanzaron las condiciones configuradas.
- Después de la recuperación, el estado de la alarma volvió a `OK`.
- Se comprobó el funcionamiento del monitoreo de infraestructura.

### 6. Destrucción de infraestructura

Después de completar las pruebas, se ejecutó la destrucción de los recursos mediante Terraform.

**Resultado final:**

```text
Apply complete! Resources: 0 added, 0 changed, 51 destroyed.
```

Se confirmó la destrucción de los 51 recursos administrados por Terraform.

### 7. Conservación del snapshot final de RDS

Antes de finalizar el laboratorio, se configuró la creación de un snapshot final de Amazon RDS.

El snapshot fue verificado mediante AWS CLI.

**Resultado comprobado:**

```text
Snapshot: cloud-lab-04-dev-mysql-final
Status: available
Type: manual
```

El snapshot quedó disponible para futuras pruebas de recuperación y Disaster Recovery.

---

## Seguridad

El proyecto incorpora las siguientes configuraciones de seguridad:

- Subredes privadas para los recursos de aplicación y base de datos.
- Roles de IAM y perfiles de instancia.
- IMDSv2 habilitado.
- Volúmenes EBS cifrados.
- Grupos de seguridad (Security Groups).
- Sin administración SSH directa.
- AWS Systems Manager Session Manager.
- Principio de mínimo privilegio.
- Acceso privado a la base de datos RDS.
- Backend remoto de Terraform cifrado.
- Bloqueo de acceso público en el bucket S3 de almacenamiento.

---

## Competencias técnicas demostradas

Este proyecto permitió desarrollar y validar conocimientos prácticos en:

- Infraestructura como Código (IaC).
- Desarrollo de módulos Terraform.
- Redes y conectividad AWS.
- Arquitecturas de alta disponibilidad.
- Auto Scaling.
- Balanceo de carga.
- Administración de instancias EC2.
- Administración de bases de datos RDS.
- Almacenamiento S3.
- Seguridad en la nube.
- Administración Linux.
- AWS Systems Manager.
- Monitoreo con CloudWatch.
- Notificaciones mediante SNS.
- Automatización con Bash.
- Automatización con Ansible.
- Administración mediante AWS CLI.
- Validación de infraestructura.
- Resolución de problemas operativos.
- Recuperación automática de servicios.

---

## Costos estimados

Este laboratorio fue desarrollado con fines educativos y de aprendizaje.

Los servicios utilizados durante el despliegue pueden generar costos en AWS, entre ellos:

| Servicio | Propósito |
|---|---|
| NAT Gateway | Conectividad saliente |
| Application Load Balancer | Distribución del tráfico |
| Amazon EC2 | Procesamiento de aplicaciones |
| Amazon RDS | Base de datos |
| Amazon S3 | Almacenamiento y estado remoto |
| Amazon CloudWatch | Monitoreo y alarmas |
| Amazon SNS | Notificaciones |
| Elastic IP | Conectividad de red |

La infraestructura principal fue destruida después de completar las pruebas.

**Nota importante:** se conservaron el bucket S3 utilizado como backend remoto de Terraform y el snapshot final de RDS. Estos recursos pueden continuar generando costos de almacenamiento.

---

## Mejoras futuras

Las siguientes funcionalidades podrían incorporarse en futuras versiones:

- AWS WAF.
- AWS Shield.
- Amazon Route 53.
- Certificados TLS mediante AWS Certificate Manager (ACM).
- Listener HTTPS.
- AWS CodePipeline.
- AWS CodeBuild.
- Despliegues Blue/Green.
- Amazon ECS.
- Amazon EKS.
- AWS Secrets Manager.
- Integración con AWS Systems Manager Parameter Store.
- AWS CloudTrail.
- AWS Config.
- Amazon GuardDuty.
- VPC Flow Logs.
- Registro centralizado de logs.
- Arquitectura Multi-Region.
- Automatización de recuperación ante desastres (Disaster Recovery).
- CI/CD mediante GitHub Actions.

---

## Capturas y evidencias

Se recomienda incluir en el repositorio las siguientes evidencias:

- Diagrama de arquitectura AWS.
- Despliegue mediante Terraform.
- Auto Scaling Group.
- Application Load Balancer.
- Panel de CloudWatch.
- Alarmas de CloudWatch.
- AWS Systems Manager Session Manager.
- Amazon RDS.
- Amazon S3.
- Notificaciones SNS.
- Prueba de carga de CPU con stress-ng.
- Historial de actividades de Auto Scaling.
- Reemplazo automático de instancia EC2.
- Resultado de Terraform Destroy.
- Estado disponible del snapshot final de RDS.

---

## Objetivos de aprendizaje

Este proyecto demuestra experiencia práctica en:

- Infraestructura AWS como Código.
- Arquitecturas de red empresariales.
- Arquitecturas de alta disponibilidad.
- Diseño modular con Terraform.
- Automatización de infraestructura.
- Administración de configuración.
- Monitoreo y observabilidad.
- Buenas prácticas de seguridad.
- Validación de infraestructura.
- Auto Scaling y recuperación automática.
- Administración de servicios AWS.
- Resolución de problemas operativos.

---

## Licencia

Este repositorio se proporciona con fines educativos.

Puede utilizarse como referencia para el aprendizaje de Infraestructura como Código y arquitectura AWS.

---

## Autor

**Bremer Quiquia**

AWS • Linux • Terraform • Ansible • Infraestructura Cloud • DevOps

---

## Estado del proyecto

**COMPLETADO — INFRAESTRUCTURA DESPLEGADA, VALIDADA Y DESTRUIDA.**

Cloud-Lab-04 fue diseñado, desplegado, automatizado y validado satisfactoriamente.

Durante las pruebas se comprobó el funcionamiento del balanceo de carga, escalamiento automático, recuperación de instancias EC2, monitoreo y generación de alertas.

Después de completar las pruebas, los 51 recursos de AWS administrados por Terraform fueron destruidos para evitar costos continuos de infraestructura.

Se conservaron el bucket S3 del backend remoto de Terraform y el snapshot final de Amazon RDS.

El código fuente permanece disponible en GitHub para futuros despliegues, pruebas y mejoras del laboratorio.
