## How to run MySQL on Azure Kubernetes Service (AKS)

First run terraform files to create AKS cluster and disk

````sh
cd terraform
terraform init
terraform apply -auto-approve
````

Change the subscription id inside single/02-mysql-pv.yaml and apply the files inside kubernetes cluster

````sh
# get AKS credentials
az aks get-credentials --resource-group rg-mysql-test --name aks-mysql-test --overwrite-existing
# create MySQL pods
kubectl apply -f single
````

Connect to MySQL, create database, table, insert data and after delete the namespace and recreate

````sh
# connect to MySQL to create database and tables
kubectl run -it mysql-test --image=mysql:8.0 -n mysql-single-test -- bash

# delete pods
kubectl delete -f single

# create again
kubectl apply -f single
````
