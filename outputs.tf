output "enabled" {
  description = "Whether the module is enabled"
  value       = local.enabled
}

output "schedule_arn" {
  description = "ARN of the EventBridge schedule"
  value       = module.schedule.arn
}

output "schedule_name" {
  description = "Name of the EventBridge schedule"
  value       = module.schedule.name
}

output "group_name" {
  description = "Schedule group the schedule belongs to"
  value       = module.schedule.group_name
}

output "role_arn" {
  description = "ARN of the invocation role used by the schedule (created or supplied)"
  value       = local.role_arn
}

output "role_name" {
  description = "Name of the created invocation role (null when create_role = false)"
  value       = try(module.scheduler_role.role_name, null)
}
