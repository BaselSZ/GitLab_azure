# Solution

## Creating the Infrastructure with Terraform

To use this solution, you first need to create a folder named ssh-keys and place your SSH public key inside it. Rename the key file to terraform-azure.pub.

Next, create a file named terraform.tfvars and add the following content:

```
resource_group_name = "YOUR-GROUP-NAME"
subscription_id     = "YOUR-SUBSCRIPTION-ID"
```

Replace YOUR-GROUP-NAME with your Azure resource group name and YOUR-SUBSCRIPTION-ID with your Azure subscription ID.

Finally, run the following commands to initialize Terraform and deploy the infrastructure:

```sh
terraform init
terraform apply
```

## Deploying the Application

1. SSH into the virtual machine `ssh -i YOUR-PRIVATE-KEY-PATH azureuser@YOUR-VM-PUBLIC-IP`
2. Install Docker using installDocker.sh script. Remember to exit the SSH session after the installation is complete and ssh back into the VM to let the Docker service start.
3. Create an `.env` file including

```env
OPENAI_API_KEY=YOUR-API-KEY
DB_NAME=YOUR-DB-NAME
DB_USER=YOUR-DB-USER
DB_PASSWORD=YOUR-DB-PASSWORD
DB_HOST=YOUR-DB-HOST
DB_PORT=YOUR-DB-PORT
```

4. Start the application using Docker Compose


```sh
docker compose up --build -d
```

In the end, you should be able to access the application via the VM’s public IP address, with data stored in the Azure Database for PostgreSQL server and files stored in Azure Blob Storage.
TEST GITHub actions!!!