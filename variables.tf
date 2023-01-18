variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
  default = "aks-tf"
}
variable "location" {
  type        = string
  description = "Resources location in Azure"
  default = "West Europe"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default = "1.25.2"
}
variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
  default = 1
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa.pub"
}