variable "description" {
  description = "Description of the schedule."
  type        = string
  default     = null
}

variable "group_name" {
  description = "Name of the schedule group this schedule belongs to."
  type        = string
  default     = "default"
}

variable "schedule_expression" {
  description = "When the schedule runs: rate(...), cron(...), or at(yyyy-mm-ddThh:mm:ss)."
  type        = string
}

variable "schedule_expression_timezone" {
  description = "IANA timezone the schedule_expression is evaluated in (e.g. UTC, Europe/London)."
  type        = string
  default     = "UTC"
}

variable "state" {
  description = "State of the schedule (ENABLED, DISABLED)."
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "state must be ENABLED or DISABLED."
  }
}

variable "flexible_time_window_mode" {
  description = "Flexible time window mode (OFF for an exact run time, FLEXIBLE to spread load)."
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "FLEXIBLE"], var.flexible_time_window_mode)
    error_message = "flexible_time_window_mode must be OFF or FLEXIBLE."
  }
}

variable "flexible_time_window_minutes" {
  description = "Maximum window in minutes when flexible_time_window_mode is FLEXIBLE (1-1440)."
  type        = number
  default     = null
}

variable "start_date" {
  description = "Optional RFC3339 timestamp before which the schedule will not invoke."
  type        = string
  default     = null
}

variable "end_date" {
  description = "Optional RFC3339 timestamp after which the schedule will no longer invoke."
  type        = string
  default     = null
}

variable "target_arn" {
  description = "ARN of the target the schedule invokes (Lambda, SQS, etc.)."
  type        = string
}

variable "target_input" {
  description = "Static JSON payload passed to the target on each invocation."
  type        = string
  default     = null
}

variable "dead_letter_arn" {
  description = "Optional SQS queue ARN for events the schedule fails to deliver."
  type        = string
  default     = null
}

variable "maximum_retry_attempts" {
  description = "Maximum retry attempts on delivery failure (0-185)."
  type        = number
  default     = null
}

variable "maximum_event_age_in_seconds" {
  description = "Maximum age of an event to keep retrying (60-86400)."
  type        = number
  default     = null
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN to encrypt the schedule's data."
  type        = string
  default     = null
}

# --- Invocation IAM role -----------------------------------------------------

variable "create_role" {
  description = "Create the EventBridge Scheduler invocation role + invoke policy. Set false to reuse role_arn."
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "Existing IAM role ARN for the scheduler to assume (used only when create_role = false)."
  type        = string
  default     = null
}

variable "target_action" {
  description = "IAM action the created role grants on target_arn (default lambda:InvokeFunction)."
  type        = string
  default     = "lambda:InvokeFunction"
}
