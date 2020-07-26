
variable "queue" {
  type        = string
  description = "sqs queue name"
}

variable "sns_topic" {
  type        = string
  description = "sns topic arn"
}

variable "dlq_max_receive_count" {
  type    = number
  default = 1
}