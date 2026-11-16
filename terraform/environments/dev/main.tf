module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  health_check_path     = "/"
}

module "launch_template" {
  source = "../../modules/launch-template"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  app_security_group_id = module.security.app_security_group_id
  root_volume_size      = var.root_volume_size
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name            = var.project_name
  environment             = var.environment
  app_subnet_ids          = module.vpc.app_subnet_ids
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = tostring(module.launch_template.launch_template_latest_version)
  target_group_arn        = module.alb.target_group_arn

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  sns_topic_arn    = module.sns.topic_arn
}

module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  db_subnet_ids           = module.vpc.db_subnet_ids
  rds_security_group_id   = module.security.rds_security_group_id
  db_instance_class       = var.db_instance_class
  db_name                 = var.db_name
  db_username             = var.db_username
  backup_retention_period = var.backup_retention_period
}

module "sns" {
  source = "../../modules/sns"

  project_name       = var.project_name
  environment        = var.environment
  notification_email = var.notification_email
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  autoscaling_group_name  = module.autoscaling.autoscaling_group_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = module.sns.topic_arn
}


module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  environment  = var.environment
  bucket_suffix = var.bucket_suffix
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
}
