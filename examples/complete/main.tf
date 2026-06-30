# Complete example: schedule the notify-deliver worker Lambda every 5 minutes.
# create_role defaults true, so the molecule also builds the EventBridge
# Scheduler invocation role and grants it lambda:InvokeFunction on target_arn.
module "notify_deliver_schedule" {
  source = "../../"

  namespace   = "eg"
  environment = "dev"
  name        = "notify-deliver"

  schedule_expression          = "rate(5 minutes)"
  schedule_expression_timezone = "UTC"

  target_arn = "arn:aws:lambda:eu-west-1:123456789012:function:eg-dev-notify-deliver"

  flexible_time_window_mode    = "FLEXIBLE"
  flexible_time_window_minutes = 2
  maximum_retry_attempts       = 3
  dead_letter_arn              = "arn:aws:sqs:eu-west-1:123456789012:eg-dev-scheduler-dlq"
}
