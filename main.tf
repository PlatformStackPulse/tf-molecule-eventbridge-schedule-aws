# =============================================================================
# Molecule: EventBridge Scheduler schedule + invocation IAM role
#
# Composes:
#   - tf-atom-eventbridge-schedule-aws  (the aws_scheduler_schedule)
#   - tf-atom-iam-role-aws              (a scheduler-assumable invocation role)
#   - tf-atom-iam-role-policy-aws       (inline policy granting invoke on target)
#
# When create_role = true (default) the molecule builds the invocation role and
# the permission to invoke var.target_arn (var.target_action, default
# lambda:InvokeFunction). Set create_role = false and pass role_arn to reuse an
# existing role.
# NOTE: the schedule atom source below is the LOCAL path for validation; on
# publish it is pinned to git::...tf-atom-eventbridge-schedule-aws?ref=<sha>.
# =============================================================================

data "aws_caller_identity" "current" {}

locals {
  role_arn = var.create_role ? try(module.scheduler_role.role_arn, null) : var.role_arn
}

module "scheduler_role" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-role-aws.git?ref=c6bc7003dc846b588c7334180f80217a3bad08f1"

  context    = module.this.context
  enabled    = var.create_role
  attributes = ["scheduler"]

  description = "EventBridge Scheduler invocation role for ${module.this.id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
      }
    }]
  })
}

module "scheduler_role_policy" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-role-policy-aws.git?ref=b0613be694daf7898f1b7a446cd1cf9808c24eab"

  context    = module.this.context
  enabled    = var.create_role
  attributes = ["scheduler"]

  role_name = module.scheduler_role.role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = var.target_action
      Resource = var.target_arn
    }]
  })

  depends_on = [module.scheduler_role]
}

module "schedule" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-eventbridge-schedule-aws.git?ref=49adb784dd46eec970d7c6abd8783624f9665360"

  context = module.this.context

  group_name                   = var.group_name
  description                  = var.description
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone
  state                        = var.state
  flexible_time_window_mode    = var.flexible_time_window_mode
  flexible_time_window_minutes = var.flexible_time_window_minutes
  start_date                   = var.start_date
  end_date                     = var.end_date

  target_arn                   = var.target_arn
  target_role_arn              = local.role_arn
  target_input                 = var.target_input
  dead_letter_arn              = var.dead_letter_arn
  maximum_retry_attempts       = var.maximum_retry_attempts
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  kms_key_arn                  = var.kms_key_arn

  depends_on = [module.scheduler_role_policy]
}
