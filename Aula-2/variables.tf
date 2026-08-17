variable "profile" {
  type = string
  description = "Perfil utilizado pelo usuario para login na AWS"
  default = null
}

variable "region" {
  type = string
  description = "Regiao da AWS"
  default = null
}

variable "state_bucket_name" {
  type = string
  description = "nome do bucket de estado"
  default = null
}

variable "project_name" {
    type = string
    description = "nome do projeto"
    default = null
}

variable "environment" {
    type = string
    description = "ambiente sendo configurado"
    default = null

    validation {
       condition = contains(["dev","prod"], var.environment)
        error_message = "Ambiente deve ser \"dev\" ou \"prod\""
    }
}

variable "cidr_block" {
    type = string
    description = "range de ips da VPC"
    default = "10.0.0.0/16"

    validation {
      condition = can(cidrnetmask(var.cidr_block))
      error_message = "ips invalidos"
    }
}