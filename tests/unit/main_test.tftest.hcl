# Unit tests for tf-molecule-eventbridge-schedule-aws
#
# Plan-only tests using a mock AWS provider — no real AWS calls are made.
# Run with:         terraform test
# Run verbose:      terraform test -verbose
# Run a single one: terraform test -run "creates_when_enabled"

mock_provider "aws" {}

# Sample inputs shared by every run block: the tf-label identity labels plus
# this molecule's required inputs (schedule_expression, target_arn).
variables {
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  schedule_expression = "rate(5 minutes)"
  target_arn          = "arn:aws:lambda:eu-west-1:123456789012:function:eg-test-thing"
}

# ---------------------------------------------------------------------------
# Test: enabled (default) — the molecule plans a schedule and an invocation role
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should report enabled == true by default."
  }

  assert {
    condition     = output.schedule_name == "eg-test-thing"
    error_message = "schedule_name should be the tf-label id derived from namespace-stage-name."
  }
}

# ---------------------------------------------------------------------------
# Test: disabled — the molecule creates nothing
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module should report enabled == false when disabled."
  }
}
