variable "cpu" {
  type = number
  default = 256
}

variable "memory" {
  type = number
  default = 512
}

variable "prometheus_port" {
  type = number
  default = 9090
}

variable "prometheus_service_name" {
    type = string
    default = "prometheus"
}
variable "grafana_port" {
  type = number
  default = 3000
}

variable "grafana_service_name" {
  type = string
  default = "grafana"
}
