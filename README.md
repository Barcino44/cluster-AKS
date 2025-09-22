# Creación de un cluster usando AKS - Terraform

## Estructura del proyecto

- `main.tf`: Contains the main configuration for the AKS cluster.
- `variables.tf`: Defines input variables for customization.
- `provider.tf`: Configures the Azure provider.
- `nginx-deployment.yaml`: Kubernetes deployment configuration for Nginx.

## Pasos seguidos

### 1. **Configuración de las credenciales de Azure:**
   Lo anterior se realiza con ayuda de.
   ````
   az login
   ````

### 3. **Inicialización de terraform:**
   Run the following command to initialize the Terraform configuration:
   ```
   terraform init
   ```
   
### 4. **Explicación del código HCL**:

  **variables.tf**
   ````
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
   ````
En este archivo son definidas las variables que serán requeridas para la inicialización del cluster.
Entre ellas se encuentran:
- El nombre del cluster
- El nombre del grupo de recursos
- La ubicación donde será desplegada el cluster
- Los nodos del que tendrá el cluster
- El tamaño/características de la máquina virtual (Nodos)

 **providers.tf**

````
  provider "azurerm" {
  features {}
  subscription_id = "5a2e3bca-ca1d-485f-bd8e-49e0b9362ec4"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  token                  = data.azurerm_kubernetes_cluster_auth.aks.kube_admin_token
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
}
````
En este archivo son definidos los proveedores que son necesarios para la inicialización del cluster.
- Azure
- Kubernetes

**main.tf:**

````
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }
}
````
Contiene el código principal para la inicialización del cluster, ente aspectos importantes se encuentran.

- La inicialización del grupo de recursos con un nombre ``"aks_rg"``
- La creación del cluster teniendo en cuenta diferentes recursos y variables
- El pool de nodos workers
- Aspectos de configuración adicionales como un load balancer y el componente de networking (CNI) a usar para la comunicación entre pods.

### 5. Validación de los cambios
Se ejecuta el siguiente comando para validar las configuraciones realizadas 
```
   terraform plan
 ```

### 6.  Aplicación de la configuración

Lo anterior con ayuda de:

```
  terraform apply
```

### 7. Despliegue del servicio de ngnix
   
   After the AKS cluster is up, apply the Nginx deployment:
```
   kubectl apply -f nginx-deployment.yaml
```

## Accessing the Nginx Website

Once the deployment is complete, you can access the Nginx website using the external IP address of the service. Use the following command to get the external IP:

```bash
kubectl get services
```

## Cleanup

To remove all resources created by Terraform, run:
```bash
terraform destroy
``` 

## License
