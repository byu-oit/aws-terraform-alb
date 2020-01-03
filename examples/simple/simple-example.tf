provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

module "acs" {
  source = "git@github.com:byu-oit/terraform-aws-acs-info.git?ref=v1.0.4"
  env    = "dev"
}

module "simple_alb" {
  source     = "git@github.com:byu-oit/terraform-aws-alb.git?ref=v1.1.0"
  name       = "simple-example"
  vpc_id     = module.acs.vpc.id
  subnet_ids = module.acs.public_subnet_ids
  target_groups = {
    main = {
      port                 = 8000
      type                 = "ip" // or instance or lambda
      deregistration_delay = null
      slow_start           = null
      health_check = {
        path                = "/"
        interval            = null
        timeout             = null
        healthy_threshold   = null
        unhealthy_threshold = null
      }
      stickiness_cookie_duration = null
    }
  }
  listeners = {
    80 = {
      redirect_to = 443
      forward_to  = null
    },
    443 = {
      redirect_to = null
      forward_to  = "main"
    }
  }
}