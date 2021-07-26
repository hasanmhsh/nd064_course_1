#We will create an linux OS on vbox to be used as cluster for kubernetes so we will use vagrant to install it for us with specs in Vagrant file 
#Check vagrant version
vagrant version
#Create vagrant box in from this directory
vatgrant up
#verify our vagrant box is running
vagrant status
#to open remote ssh with vagrant running os 
cd directoryOfVagrantConjfigFileWhichIsThisFolder
vagrant ssh
#Now start to install kubernetes cluster within vagrant os
#We will use K3S https://k3s.io
curl -sfL https://get.k3s.io | sh -
# Check for Ready node,takes maybe 30 seconds
sudo su
kubectl get no
# k3s kubectl get node
#kubectl is the cluster CLI
#Access to cluster is allowed to users who have kubeconfig file in their home directory ~/.kube/config 
#k3s places the kubeconfig file within /etc/rancher/k3s/k3s.yaml
#kubeconfig file can be set through the --kubeconfig kubectl flag or via exporting the KUBECONFIG environmental variable.


#Ensure Docker is installed and running. Use the docker --version command to verify if Docker is installed.
docker --version
#If docker not installed install it using the following command see installing-docker-and-running-it-without-root-login-with-vagrant-user
#or use the following as root
zypper install docker
#Then run docker daemon
#systemctl --user start docker
#systemctl --user enable docker
#sudo loginctl enable-linger $(whoami)
systemctl start docker
systemctl enable docker

#Install kind by using the official installation documentation https://kind.sigs.k8s.io/docs/user/quick-start/#installation
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind # you can move it to home directory or another place to execute in it (such as /opt) or leave it in the downloading directory
#not that kind is an executable file which is product of installation of kind tool
#Create a kind cluster using the kind create cluster --name demo command
./kind create cluster --name demo

#Inspect  the endpoints for the cluster and installed add-ons 
kubectl cluster-info

# List all the nodes in the cluster. 
# To get a more detailed view of the nodes, the `-o wide` flag can be passed (more detailed output , wider output is required)
kubectl get no
kubectl get nodes [-o wide] 

# Describe a cluster node.
# Typical configuration: node IP, capacity (CPU and memory), a list of running pods on the node, podCIDR, etc.
kubectl describe node {{ NODE NAME }} #name may be control-plane or localhost as configured in kubelet
# Note that podCIDR field in the result of last command identify the range of IPs to the pods running on this particular node ex:10.244.0.0/24
#The last thing you can observe in the output of last command is a list of all running pods(Non-terminated Pods:) on this node then list of events

#=========================================Start deploying apps(pods) to kubernetes======================
#Note that every pod often run in standalone container
#Note that deployment is a large category which contain multiple pods and replica sets and services

#List all deployments to current kubernetes cluster
kubectl get deploy
#This output "No resources found in default namespace." means no deployment , our cluster is clear

#List all replica sets
kubectl get rs

#List all pods
kubectl get po

#image will be pulled auomatically from docker hub during deployment creation

#Create deployment
kubectl create deploy go-helloworld --image=hasanmhsh/go-helloworld:v5.12.3 --port 6111

#Verify
kubectl get deploy
kubectl get rs
kubectl get po


#to access go-helloworld app from your local host , you need to set port forward port forward work on the same vm OS not host OS
kubectl port-forward po/[pod-name] app-port-number:port-number-exposed-to-local-host  #get pod name by "kubectl get po"
kubectl port-forward po/go-helloworld-79fcd5dd4-mdknl 6111:6111

#delete deployment 
kubectl delete deploy [deployment-name]

#delete pod
kubectl delete pods [pod-name]


#!!!!!Important
#Now we will edit configuration of go-helloworld deployment
#We will change docker image to another one then save the deployment
#After editing configuration kubernetes will create new replica-set(instance of running container) with new configuration
#Then stop the first running replica-set
#Old pod will be deleted and new one will be created for new deployment

#Edit deployment
#Output will be formated in YAML as specified in the next command 
kubectl edit deploy go-helloworld -o yaml
#it will open vim editor just press i to enter insert mode then edit image name or version then pres ESC then :wq! to save and exit

#Verify
kubectl get rs
kubectl get po

#==================================Access pods==============================
#Every pod has a single ip to be accessed with , pods are accissible within cluster an not accissible from outside cluster
#You will create "Service resource" which will expose single service ip for all pods and route requests to available pods (Up and running pods)
#You have 3 types of services which exposes single ip for all pods
#1-ClusterIP (default) : This ip is only accessible inside the cluster so workloads can refer to it securely, if no service ip type is specified a cluster ip will be created by default.
#2-NodePort : exposes the service using a port on the node, All the nodes in the cluster will expose the same port and route the traffic to the application.
#3-LoadBalancer : Which exposes the service through a load balancer from a public cloud provider sucjh as AWS, AZURE or GCP , this will allow the external traffic to reach these services within the cluster securely.

#Before creating new service take alook to list of services within your namespace
kubectl get svc

#To create a service for an existing deployment use this command

# expose a Deployment through a Service resource 
# NAME - required; set the name of the deployment to be exposed
# --port - required; specify the port that the service should serve on
# --target-port - optional; specify the port on the container that the service should direct traffic to
# FLAGS - optional; provide extra configuration parameters for the service
kubectl expose deploy NAME --port=port [--target-port=port] [FLAGS]

# Some of the widely used FLAGS are:
--protocol - set the network protocol. Options [TCP|UDP|SCTP] TCP is the default
--type - set the type of service. Options [ClusterIP, NodePort, LoadBalancer] ClusterIP is the default


# expose the `go-helloworld` deployment on port 8111
# note: the application is serving requests on port 6112
kubectl expose deploy go-helloworld --port=8111 --target-port=6112

#verify
kubectl get svc

#Please pay attention , all pods in the deployment are in the same subnet , all we want to do is
#We want to test accessing our go-helloworld main pod from another pod in the same deployment to verify that ClusterIP service is running properly and is accissible inside cluster and is inaccessible outside cluster
#First we will create new pod with instant opened interactive shell to make request with wget or curl to go-helloworld main pod
#Create new pod for test with the following command
kubectl run test-$RANDOM --namespace=default --rm -it --image=alpine -- sh
#test-$RANDOM => use an name , RANDOM variable is similar to math.random() method which generate random integer so our new pod name will be something like "test-7634"
#--rm => remove or delete pod once interactive shell is exited
#--it => opent interactive terminal to new pod immediately after creating and running it
#--image=alpine => this pod should run the alpine image
#Now after hitting enter new pod is created and anew shell is opened to the new pod so now you can send request to the main pod using ip obtained before by `kubectl get svc` command               
#Make the request in new shell with the following command
wget -qO- 10.43.243.198:8111

#Previosly you have known that load balancer services allow external access to the service within the cluster,
#however having an actual load balancer per application is extremely expensive as cloud provider charge quite high for these resources,
#it is most common to allocate a load balancer per bussiness vertical or function, which will direct the traffic to multiple applications 


#Ingress (look at ingress.png)
#To enable the external user to access services within the cluster an Ingress resource is necessary. An Ingress exposes HTTP and HTTPS routes to services within the cluster, 
#using a load balancer provisioned by a cloud provider. Additionally, an Ingress resource has a set of rules that are used to map HTTP(S) endpoints to services running in the cluster. 
#To keep the Ingress rules and load balancer up-to-date an Ingress Controller is introduced.
#For example, as shown in the image above, the customers will access the go-helloworld.com/hi HTTP route (1), 
#which is managed by an Ingress (2). The Ingress Controller (3) examines the configured routes and directs the traffic to a LoadBalancer (4). And finally, the LoadBalancer directs the requests to the pods using a dedicated port (5).

#==================================================================================================================
#In the implementation phase, a good development practice is to separate the configuration from the bussiness logic (source code). 
#This increased the portability of an application as it can cover multiple customer use cases
# Kubernetes has 2 resources to pass data to an application: Configmaps and Secrets.



# ConfigMaps--------------------------------------------------------------------------------

# ConfigMaps are objects that store non-confidential data in key-value pairs. 
# A Configmap can be consumed by a pod as an environmental variable, configuration files through a volume mount, or as command-line arguments to the container.

# To create a Configmap resource use the kubectl create configmap command, with the following syntax:

# create a Configmap
# NAME - required; set the name of the configmap resource
# FLAGS - optional; define  extra configuration parameters for the configmap
kubectl create configmap NAME [FLAGS]

# Some of the widely used FLAGS are:
--from-file - set path to the file that contains the key-value pairs 
--from-literal - set key-value pair from command-line 

# For example, to create a Configmap to store the background color for a front-end application, the following command can be used:
# create a Configmap to store the color value
# kubectl create configmap test-cm --from-literal=color=blue



# First list all config maps in the current namespace
kubectl get cm
# create a Configmap to store the color value
kubectl create configmap test-cm --from-literal=color=blue
# Show details of config map
kubectl describe cm test-cm


# Secrets-------------------------------------------------------------------------------

# Secrets are used to store and distribute sensitive data to the pods, such as passwords or tokens. 
# Pods can consume secrets as environment variables or as files from the volume mounts to the pod. It is noteworthy, that Kubernetes will encode the secret values using base64.

# To create a Secret use the kubectl create secret generic command, with the following syntax:

# create a Secret
# NAME - required; set the name of the secret resource
# FLAGS - optional; define  extra configuration parameters for the secret
kubectl create secret generic NAME [FLAGS]

# Some of the widely used FLAGS are:
# --from-file - set path to file with the sensitive key-value pairs 
# --from-literal - set key-value pair from command-line 

# For example, to create a Secret to store the secret background color for a front-end application, the following command can be used:

# create a Secret to store the secret color value
kubectl create secret generic test-secret --from-literal=color=red


# First list all secrets in the current namespace
kubectl get secrets
# create a secret to store the secret color value
kubectl create secret generic test-secret --from-literal=color=red
# Show details of secret
kubectl describe secrets test-secret
# Show details of secret in yaml format
kubectl describe secrets test-secret -o yaml # not working
# secret value is encoded using base-64 encoder and will exactly be "cmVk"
# To decode it use the following command which will produce "red"
echo "cmVk" | base64 -d



# Namespaces--------------------------------------------------------------------------

# A Kubernetes cluster is used to host hundreds of applications, and it is required to have separate execution environments across teams and business verticals.
# This functionality is provisioned by the Namespace resources. 
# A Namespace provides a logical separation between multiple applications and associated resources. 
# In a nutshell, it provides the application context, defining the environment for a group of Kubernetes resources that relate to a project,
# such as the amount of CPU, memory, and access. For example, a project-green namespace includes any resources used to deploy the Green Project.
# These resources construct the application context and can be managed collectively to ensure a successful deployment of the project.

# Each team or business vertical is allocated a separate Namespace, with the desired amount of CPU, memory, and access. 
# This ensures that the application is managed by the owner team and has enough resources to execute successfully.
# This also eliminates the "noisy neighbor" use case, where a team can consume all the available resources in the cluster if no Namespace boundaries are set.

# To create a Namespace we can use the kubectl create namespace command, with the following syntax:

# create a Namespace
# NAME - required; set the name of the Namespace
kubectl create ns NAME

# For example, to create a test-udacity Namespace, the following command can be used:

# First list all namespaces within cluster
kubectl get ns

# create a `test-udacity` Namespace
kubectl create ns test-udacity

# get all the pods in the `test-udacity` Namespace
kubectl get po -n test-udacity


# get all the pods in the `default` Namespace
kubectl get po -n default

# get all the deployments in the `default` Namespace
kubectl get deployment -n default

# get all the replica sets in the `default` Namespace
kubectl get rs -n default

# To create any resource (deployment, pod, replica set , service , config map , secret .....etc) within particular namespace (test-udacity for example)
kubectl create { resource } [......options] -n test-udacity




# # ========================================USeful kubernetes commands===================================
# Kubectl provides a rich set of actions that can be used to interact, manage, and configure Kubernetes resources. Below is a list of handy kubectl commands used in practice.

# Note: In the following commands the following arguments are used:

#     RESOURCE is the Kubernetes resource type
#     NAME sets the name of the resource
#     FLAGS are used to provide extra configuration
#     PARAMS are used to provide the required configuration to the resource

# Create Resources

# To create resources, use the following command:

kubectl create RESOURCE NAME [FLAGS]

# Describe Resources

# To describe resources, use the following command:

kubectl describe RESOURCE NAME 

# Get Resources

# To get resources, use the following command, where -o yaml instructs that the result should be YAML formated.

kubectl get RESOURCE NAME [-o yaml]

# Edit Resources

# To edit resources, use the following command, where -o yaml instructs that the edit should be YAML formated.

kubectl edit RESOURCE NAME [-o yaml]

# Label Resources

# To label resources, use the following command:

kubectl label RESOURCE NAME [PARAMS]

# Port-forward to Resources

# To access resources through port-forward, use the following command:

kubectl port-forward RESOURCE/NAME [PARAMS]

# Logs from Resources

# To access logs from a resource, use the following command:

kubectl logs RESOURCE/NAME [FLAGS]

# Delete Resources

# To delete resources, use the following command:

kubectl delete RESOURCE NAME

# ===============================================End of useful kubernetes commands===============================