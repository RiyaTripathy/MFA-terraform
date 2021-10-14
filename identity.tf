variable "org_name" {}
variable "api_token" {}
variable "base_url" {}

provider "okta" {
    org_name = var.org_name
    base_url = var.base_url
    api_token = var.api_token
}
resource "okta_group" "AGENTHQ" {
  name        = "AGENTHQ"
  description = "Group for AgentHQ users"
}
data "okta_group" "AGENTHQ_member" {
  name = "AGENTHQ"
} 


resource "okta_policy_mfa" "AGENTHQ_MFA" {
  name        = "AGENTHQ MFA"
  status      = "ACTIVE"
  description = "MFA policy for AGENTHQ"

  okta_otp = {
    enroll = "OPTIONAL"
  }
  okta_push = {
      enroll = "OPTIONAL"
  }
  okta_sms = {
   enroll = "OPTIONAL"
  }
  
  

  groups_included = [data.okta_group.AGENTHQ_member.id]
}

resource "okta_factor" "sms" {
  provider_id = "okta_sms"
}

resource "okta_factor" "oktaverify" {
  provider_id = "okta_push"
}



data "okta_policy" "MFA_policy"{
name = "AGENTHQ MFA"
type = "MFA_ENROLL"
}
resource "okta_policy_rule_mfa" "AGENTHQ_MFA_Rule" {
  name        = "AGENTHQ MFA Rule"
  policyid      = data.okta_policy.MFA_policy.id
  status      = "ACTIVE"
  enroll = "LOGIN"
  }
  
resource "okta_policy_signon" "AGENTHQ_Signon" {
  name            = "AGENTHQ Signon"
  status          = "ACTIVE"
  description     = "Sign on policy for agenthq"
  groups_included = [data.okta_group.AGENTHQ_member.id]
}
data "okta_policy" "SignOn_policy"{
name = "AGENTHQ Signon"
type = "OKTA_SIGN_ON"
}
resource "okta_policy_rule_signon" "AGENTHQ_Signon_Rule" {
  access = "ALLOW"
  authtype = "ANY"
  name = "AGENTHQ Policy Rule"
  network_connection = "ANYWHERE"
  policyid = data.okta_policy.SignOn_policy.id
  status = "ACTIVE"
  mfa_required = "true"
  mfa_prompt = "ALWAYS"
  }