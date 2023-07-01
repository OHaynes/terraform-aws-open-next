variable "prefix" {
  description = "A prefix which will be attached to the resource name to ensure resources are random"
  type        = string
  default     = null
}

variable "suffix" {
  description = "A suffix which will be attached to the resource name to ensure resources are random"
  type        = string
  default     = null
}

variable "iam" {
  description = "Override the default IAM configuration"
  type = object({
    path                 = optional(string, "/")
    permissions_boundary = optional(string)
  })
  default = {}
}

variable "cloudwatch_log" {
  description = "Override the Cloudwatch logs configuration"
  type = object({
    retention_in_days = number
  })
  default = {
    retention_in_days = 7
  }
}

variable "preferred_architecture" {
  description = "Preferred instruction set architecture for the lambda function. If lambda@edge is used for the server function, the architecture will be set to x86_64 for that function"
  type        = string
  default     = "arm64"
}

variable "vpc" {
  description = "The default VPC configuration for the lambda resources. This can be overridden for each function"
  type = object({
    security_group_ids = list(string),
    subnet_ids         = list(string)
  })
  default = null
}

variable "open_next" {
  description = "The next.js website config for single and multi-zone deployments"
  type = object({
    exclusion_regex  = optional(string)
    root_folder_path = string
    additional_zones = optional(list(object({
      name        = string
      http_path   = string
      folder_path = string
    })), [])
  })
}

variable "cache_control_immutable_assets_regex" {
  description = "Regex to set public,max-age=31536000,immutable on immutable resources"
  type        = string
  default     = "^.*(\\.js|\\.css|\\.woff2)$"
}

variable "content_types" {
  description = "The MIME type mapping and default for artefacts generated by Open Next"
  type = object({
    mapping = optional(map(string), {
      "svg" = "image/svg+xml",
      "js"  = "application/javascript",
      "css" = "text/css",
    })
    default = optional(string, "binary/octet-stream")
  })
  default = {}
}

variable "domain" {
  description = "Configuration to for attaching a custom domain to the CloudFront distribution"
  type = object({
    create                 = optional(bool, false)
    hosted_zone_name       = optional(string),
    name                   = optional(string),
    alternate_names        = optional(list(string), [])
    acm_certificate_arn    = optional(string),
    evaluate_target_health = optional(bool, false)
  })
  default = {}
}

variable "cloudfront" {
  description = "Configuration for the CloudFront distribution"
  type = object({
    enabled                  = optional(bool, true)
    invalidate_on_change     = optional(bool, true)
    minimum_protocol_version = optional(string, "TLSv1.2_2021")
    ssl_support_method       = optional(string, "sni-only")
    http_version             = optional(string, "http2and3")
    ipv6_enabled             = optional(bool, true)
    price_class              = optional(string, "PriceClass_100")
    geo_restrictions = optional(object({
      type      = optional(string, "none"),
      locations = optional(list(string), [])
    }), {})
  })
  default = {}
}

variable "warmer_function" {
  description = "Configuration for the warmer function"
  type = object({
    create      = bool
    runtime     = optional(string, "nodejs18.x")
    concurrency = optional(number, 20)
    timeout     = optional(number, 15 * 60) // 15 minutes
    memory_size = optional(number, 1024)
    schedule    = optional(string, "rate(5 minutes)")
    additional_environment_variables = optional(map(string), {})
    additional_iam_policies = optional(list(object({
      name = string,
      arn  = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
  })
  default = {
    create = false
  }
}

variable "server_function" {
  description = "Configuration for the server function"
  type = object({
    runtime     = optional(string, "nodejs18.x")
    deployment  = optional(string, "REGIONAL_LAMBDA")
    timeout     = optional(number, 10)
    memory_size = optional(number, 1024)
    additional_environment_variables = optional(map(string), {})
    additional_iam_policies = optional(list(object({
      name = string,
      arn  = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
  })
  default = {}

  validation {
    condition     = contains(["API_GATEWAY", "REGIONAL_LAMBDA", "EDGE_LAMBDA"], var.server_function.deployment)
    error_message = "The server function deployment can be one of API_GATEWAY, REGIONAL_LAMBDA or EDGE_LAMBDA"
  }
}

variable "image_optimisation_function" {
  description = "Configuration for the image optimisation function"
  type = object({
    runtime     = optional(string, "nodejs18.x")
    deployment  = optional(string, "REGIONAL_LAMBDA")
    timeout     = optional(number, 25)
    memory_size = optional(number, 1536)
    additional_environment_variables = optional(map(string), {})
    additional_iam_policies = optional(list(object({
      name = string,
      arn  = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
  })
  default = {}

  validation {
    condition     = contains(["API_GATEWAY", "REGIONAL_LAMBDA"], var.image_optimisation_function.deployment)
    error_message = "The image optimisation function deployment can be either API_GATEWAY or REGIONAL_LAMBDA"
  }
}


variable "isr" {
  description = "Configuration for ISR, including creation and function config. To use ISR you need to use at least 2.x of Open Next, for 1.x please set create to false"
  type = object({
    create = bool
    revalidation_function = optional(object({
      runtime     = optional(string, "nodejs18.x")
      deployment  = optional(string, "REGIONAL_LAMBDA")
      timeout     = optional(number, 30)
      memory_size = optional(number, 128)
      additional_environment_variables = optional(map(string), {})
      additional_iam_policies = optional(list(object({
        name = string,
        arn  = optional(string)
        policy = optional(string)
      })), [])
      vpc = optional(object({
        security_group_ids = list(string),
        subnet_ids         = list(string)
      }))
    }), {})
  })
  default = {
    create = true
  }
}
