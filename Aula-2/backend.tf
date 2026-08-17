terraform {
    backend "s3"{
        bucket = "terraform-state-watadados-iac-course"
        key = "watadados-iac/dev/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        profile = "watadados"

        use_lockfile = true
    }
}