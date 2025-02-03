rule "terraform_required_version" {
  enabled = false
}

rule "terraform_module_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}
rule "terraform_module_pinned_source"{
    enabled = false
}
