# Creating an AKS Cluster with Terraform

## Project Structure

- `main.tf`: Main cluster configuration.  
- `variables.tf`: Variable definitions.
- `provider.tf`: Providers configuration.  
- `nginx-deployment.yaml`: Nginx deployment and service configuration.

## Steps followed

### 1. **Configuring Azure credentials:**

This is done with the help of

   ````
   az login
   ````

### 3. **Terraform Initialization:**
   
The following was executed to initialize terraform.
   
   ```
   terraform init
   ```
   
### 4. **HCL Code Explanation**:

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
This file defines the variables required for cluster initialization.
These include:
- The cluster name
- The resource group name
- The location where the cluster will be deployed
- The number of nodes the cluster will have
- The size/characteristics of the virtual machine (nodes)

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

This file defines the providers required for cluster initialization.
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
It contains the main code for cluster initialization. Important aspects include:

- Initialization of the resource group with the name "aks_rg"
- Creation of the cluster, taking into account different resources and variables
- The pool of worker nodes
- Additional configuration aspects such as a load balancer and the networking component (CNI) to use for inter-pod communication.

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

It contains all the necessary information for server deployment within the cluster. Important aspects include.

- The deployment that builds three replicas and uses the latest nginx image.
- The service that exposes the nginx service on port 80.

### 5. Validating Changes

Run the following command to validate the configurations made.

```
   terraform plan
 ```

### 6. Applying the Configuration

The above with the help of.

```
  terraform apply
```

After completing the above, you can view the creation of the cluster and its required resources in the Azure portal.

<p align="center">
   <img width="1516" height="657" alt="image" src="https://github.com/user-attachments/assets/0cf32ad7-cb4d-4bdb-919f-9d381e5f6797" />
</p>

<p align="center">
   <img width="1516" height="618" alt="image" src="https://github.com/user-attachments/assets/280c7c90-66f7-452b-a122-5994421a3ef8" />
</p>

### 7. Deploying the nginx service

Once the cluster is in good working order, its credentials are used to access it. This is done with the help of the following command.

````
az aks get-credentials --resource myResourceGroup --name myakscluster
````

The deployment and subsequent creation of the service is then carried out with the help of.

```
   kubectl apply -f nginx-deployment.yaml
```

We can see the pods created with the help of the deployment.

<p align="center">
   <img width="749" height="115" alt="image" src="https://github.com/user-attachments/assets/faee513d-fafa-44fa-9462-0d5f1c672398" />
</p>

### 8. Access the nginx web server

Once the deployment is complete, you can access the website using the external IP of the created service. This can be done with the help of:

```
   kubectl get services
```
<p align="center">
   <img width="756" height="110" alt="image" src="https://github.com/user-attachments/assets/92986046-967c-4a0f-a02a-d13c53ca311f" />
</p>

<p align="center">
   <img width="1421" height="376" alt="image" src="https://github.com/user-attachments/assets/1cb53103-aa9c-43ad-bb52-bd25b9a1faf8" />
</p>

### 9. Connecting to k8s-lens

To connect to lens, download it using the link.

````
https://k8slens.dev/
````

Once downloaded, the interface was accessed.

Then, the ``.kube/config`` file was added. This allowed access to the monitoring system.

<p align="center">
   <img width="929" height="580" alt="image" src="https://github.com/user-attachments/assets/7131f5b2-dc3a-4899-ad66-95e99e09da18" />
</p>

<p align="center">
   <img width="1919" height="983" alt="image" src="https://github.com/user-attachments/assets/5e3c5a62-6a89-4380-a2e8-72a2104680a1" />
</p>


### 10. Resources cleaning

Cleaning of resources is done with the help of.

```
terraform destroy
```


