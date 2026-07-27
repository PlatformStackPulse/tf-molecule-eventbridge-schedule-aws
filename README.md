# tf-molecule-eventbridge-schedule-aws

[![Terraform Format](https://img.shields.io/badge/terraform-fmt-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![Terraform Validate](https://img.shields.io/badge/terraform-validate-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![TFLint](https://img.shields.io/badge/tflint-passing-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![Terraform Test](https://img.shields.io/badge/tests-2%20passed-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![Security Scan](https://img.shields.io/badge/trivy-passing-brightgreen?logo=aqua)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-blue?logo=conventionalcommits)](https://conventionalcommits.org)
[![Documentation](https://img.shields.io/badge/docs-terraform--docs-blue?logo=readthedocs)](https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws/actions)
[![License](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)

Amazon EventBridge Scheduler schedule **plus** its invocation IAM role — the modern,
recommended way to run a Lambda (or other target) on a cron/rate/at schedule. This is
the EventBridge **Scheduler** (`aws_scheduler_schedule`), not a CloudWatch Events
scheduled rule (for that, see `tf-molecule-eventbridge-rule-target-aws`).

Composes `tf-atom-eventbridge-schedule-aws` + `tf-atom-iam-role-aws` +
`tf-atom-iam-role-policy-aws`. With `create_role = true` (default) it builds a
scheduler-assumable role and grants it `lambda:InvokeFunction` (or `target_action`)
on `target_arn`; set `create_role = false` and pass `role_arn` to reuse a role.

## Features

- Creates an EventBridge **Scheduler** schedule (`aws_scheduler_schedule`) driven by a
  `rate(...)`, `cron(...)`, or `at(...)` `schedule_expression`.
- Optionally builds a scheduler-assumable IAM invocation role (`create_role = true`,
  default) scoped to the current account via `aws:SourceAccount`, with an inline policy
  granting `target_action` (default `lambda:InvokeFunction`) on `target_arn`. Set
  `create_role = false` and pass `role_arn` to reuse an existing role.
- Supports a flexible time window (`flexible_time_window_mode` + `flexible_time_window_minutes`)
  to spread invocations, plus an explicit IANA `schedule_expression_timezone`.
- Bounds delivery with `maximum_retry_attempts`, `maximum_event_age_in_seconds`, and an
  optional `dead_letter_arn` SQS target for undeliverable events.
- Optional `start_date` / `end_date` activation window, static `target_input` payload,
  customer-managed `kms_key_arn` encryption, and schedule `group_name`.
- Toggle the whole molecule on/off with `enabled` (via the tf-label `context`); when
  disabled it creates no resources.

## Usage

```hcl
module "notify_deliver_schedule" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-eventbridge-schedule-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "notify-deliver"

  schedule_expression = "rate(5 minutes)"
  target_arn          = module.notify_deliver_lambda.function_arn

  flexible_time_window_mode    = "FLEXIBLE"
  flexible_time_window_minutes = 2
  maximum_retry_attempts       = 3
  dead_letter_arn              = module.scheduler_dlq.queue_arn
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_schedule"></a> [schedule](#module\_schedule) | git::https://github.com/PlatformStackPulse/tf-atom-eventbridge-schedule-aws.git | 49adb784dd46eec970d7c6abd8783624f9665360 |
| <a name="module_scheduler_role"></a> [scheduler\_role](#module\_scheduler\_role) | git::https://github.com/PlatformStackPulse/tf-atom-iam-role-aws.git | c6bc7003dc846b588c7334180f80217a3bad08f1 |
| <a name="module_scheduler_role_policy"></a> [scheduler\_role\_policy](#module\_scheduler\_role\_policy) | git::https://github.com/PlatformStackPulse/tf-atom-iam-role-policy-aws.git | b0613be694daf7898f1b7a446cd1cf9808c24eab |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |

### Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | When the schedule runs: rate(...), cron(...), or at(yyyy-mm-ddThh:mm:ss). | `string` | n/a | yes |
| <a name="input_target_arn"></a> [target\_arn](#input\_target\_arn) | ARN of the target the schedule invokes (Lambda, SQS, etc.). | `string` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Create the EventBridge Scheduler invocation role + invoke policy. Set false to reuse role\_arn. | `bool` | `true` | no |
| <a name="input_dead_letter_arn"></a> [dead\_letter\_arn](#input\_dead\_letter\_arn) | Optional SQS queue ARN for events the schedule fails to deliver. | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the schedule. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_end_date"></a> [end\_date](#input\_end\_date) | Optional RFC3339 timestamp after which the schedule will no longer invoke. | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_flexible_time_window_minutes"></a> [flexible\_time\_window\_minutes](#input\_flexible\_time\_window\_minutes) | Maximum window in minutes when flexible\_time\_window\_mode is FLEXIBLE (1-1440). | `number` | `null` | no |
| <a name="input_flexible_time_window_mode"></a> [flexible\_time\_window\_mode](#input\_flexible\_time\_window\_mode) | Flexible time window mode (OFF for an exact run time, FLEXIBLE to spread load). | `string` | `"OFF"` | no |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name of the schedule group this schedule belongs to. | `string` | `"default"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional customer-managed KMS key ARN to encrypt the schedule's data. | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_maximum_event_age_in_seconds"></a> [maximum\_event\_age\_in\_seconds](#input\_maximum\_event\_age\_in\_seconds) | Maximum age of an event to keep retrying (60-86400). | `number` | `null` | no |
| <a name="input_maximum_retry_attempts"></a> [maximum\_retry\_attempts](#input\_maximum\_retry\_attempts) | Maximum retry attempts on delivery failure (0-185). | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Existing IAM role ARN for the scheduler to assume (used only when create\_role = false). | `string` | `null` | no |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | IANA timezone the schedule\_expression is evaluated in (e.g. UTC, Europe/London). | `string` | `"UTC"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_start_date"></a> [start\_date](#input\_start\_date) | Optional RFC3339 timestamp before which the schedule will not invoke. | `string` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | State of the schedule (ENABLED, DISABLED). | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_target_action"></a> [target\_action](#input\_target\_action) | IAM action the created role grants on target\_arn (default lambda:InvokeFunction). | `string` | `"lambda:InvokeFunction"` | no |
| <a name="input_target_input"></a> [target\_input](#input\_target\_input) | Static JSON payload passed to the target on each invocation. | `string` | `null` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | Schedule group the schedule belongs to |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the invocation role used by the schedule (created or supplied) |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the created invocation role (null when create\_role = false) |
| <a name="output_schedule_arn"></a> [schedule\_arn](#output\_schedule\_arn) | ARN of the EventBridge schedule |
| <a name="output_schedule_name"></a> [schedule\_name](#output\_schedule\_name) | Name of the EventBridge schedule |
<!-- END_TF_DOCS -->

## Tests

Plan-only unit tests (mock AWS provider — no real AWS calls) live under `tests/unit/`.

```bash
terraform init -backend=false && terraform test -test-directory=tests/unit
# or, via the Makefile:
make test-unit
```
