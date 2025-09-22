variable "aks_cluster_name" {
  description = "The name of the Azure Kubernetes Service cluster"
  type        = string
  default     = "myakscluster"
}

variable "resource_group_name" {
  description = "The name of the resource group where the AKS cluster will be created"
  type        = string
  default     = "myResourceGroup"
}

variable "location" {
  description = "The Azure region where the resources will be deployed"
  type        = string
  default     = "East US"
}

variable "node_count" {
  description = "The number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "The size of the virtual machines for the AKS nodes"
  type        = string
  default     = "standard_a2_v2"
}