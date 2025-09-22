provider "azurerm" {
  features {}
  subscription_id = "5a2e3bca-ca1d-485f-bd8e-49e0b9362ec4"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  token                  = data.azurerm_kubernetes_cluster_auth.aks.kube_admin_token
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
}