# Creación de un cluster usando AKS - Terraform

## Estructura del proyecto

- `main.tf`: Configuración principal.
- `variables.tf`: Configuración de las variables.
- `provider.tf`: Configuración de los proveedores.
- `nginx-deployment.yaml`: Para el despligue de un servidor web.

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

**nginx-deployment.yaml**  

````
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
````

Contiene toda la información necesaria para el despliegue de servidor al interior del cluster. Entre aspectos importantes se encuentran.

- El deployment que construye 3 replicas y emplea la última imagen de nginx.
- El service que expone le servicio de nginx por el puerto 80.

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

Tras realizar lo anterior, se puede visualizar en el portal de azure la creación del cluster y sus recursos necesarios.

<p align="center">
   <img width="1516" height="657" alt="image" src="https://github.com/user-attachments/assets/0cf32ad7-cb4d-4bdb-919f-9d381e5f6797" />
</p>

<p align="center">
   <img width="1516" height="618" alt="image" src="https://github.com/user-attachments/assets/280c7c90-66f7-452b-a122-5994421a3ef8" />
</p>

### 7. Despliegue del servicio de ngnix

Una vez el cluster se encuentre en correcto estado se usan sus credenciales para acceder a él. Lo anterior con ayuda del siguiente comando.

````
az aks get-credentials --resource myResourceGroup --name myakscluster
````

Posteriormente se realiza el deployment y la posterior creación del servicio con ayuda de.

```
   kubectl apply -f nginx-deployment.yaml
```

Podemos los pods creados con ayuda del deployment
<p align="center">
   <img width="749" height="115" alt="image" src="https://github.com/user-attachments/assets/faee513d-fafa-44fa-9462-0d5f1c672398" />
</p>

### 8. Accesso al servidor web de nginx

Una vez el despliegue este listo, se puede acceder al sitio web usando la ip externa del servicio creado. Lo anterior con ayuda de.

```
   kubectl get services
```
<p align="center">
   <img width="756" height="110" alt="image" src="https://github.com/user-attachments/assets/92986046-967c-4a0f-a02a-d13c53ca311f" />
</p>

<p align="center">
   <img width="1421" height="376" alt="image" src="https://github.com/user-attachments/assets/1cb53103-aa9c-43ad-bb52-bd25b9a1faf8" />
</p>

### 9. Conexión con k8s-lens

Para realizar la conexión con lens, se realizó la descarga mediante el link.
````
https://k8slens.dev/
````
Una vez descargada, se accedió a la interfaz. 
Posteriormente, fue añadido el archivo ``.kube/config. `` Al hacer esto, se pudo acceder al sistema de monitoreo.

<p align="center">
   <img width="929" height="580" alt="image" src="https://github.com/user-attachments/assets/7131f5b2-dc3a-4899-ad66-95e99e09da18" />
</p>

<p align="center">
   <img width="1919" height="983" alt="image" src="https://github.com/user-attachments/assets/5e3c5a62-6a89-4380-a2e8-72a2104680a1" />
</p>


### 10. Limpieza de recursos

La limpieza de los recursos se realiza con ayuda de.

```
terraform destroy
```


