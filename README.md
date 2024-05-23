**PROJECT 4: Setting Up a Kubernetes Cluster and Demo on AWS EKS**

**Project Description:**

Kubernetes Cluster setup and demo

**Goals**:

1\. Kubernetes is one of the most popular container orchestration tools available. The

Container Orchestration will help you grasp the key skills, technology, and

concepts that a Kubernetes administrator needs to know.

**Technologies Used:**

1\. Docker

2\. YAML

3\. Kubernetes

4\. Container Networking

**Steps:**

1\. Installation and setup of Kubernetes cluster \[EKS\]

2\. Configuring YAML files for K8s deployment

3\. Autoscaling and Load Balancing in Kubernetes

4\. Registering services through Kubernetes Deployment through Kubernetes

**Setting Up a Kubernetes Cluster and Demo on AWS EKS**

This guide walks you through creating a minimal Kubernetes cluster on Amazon Elastic Kubernetes Service (EKS) and deploying a simple application. We'll explore core functionalities with commands and explanations.

**Prerequisites:**

- An AWS account with IAM, EC2, VPC, and EKS service access.
- Docker installed and running on your local machine.
- Basic understanding of YAML syntax.

**1\. Setting Up the EKS Cluster:**

**1.1 IAM Role Creation:**

We'll need an IAM role for EKS to manage AWS resources. Use the AWS CLI with the following command:

Bash
~~~
aws iam create-role \
--role-name eks-cluster-role \
--assume-role-policy-document file://eks-trust-policy.json
~~~

trust-policy.json **with the path to a file containing the following JSON policy:**

JSON
~~~
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "eks.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
~~~

**1.2 VPC Creation:**

Use the AWS Management Console or the AWS CLI to create a VPC with subnets for your worker nodes. This step might involve multiple commands depending on your desired VPC configuration.

**1.3 EKS Cluster Creation:**

We'll use eksctl (install it following the guide at <https://docs.aws.amazon.com/eks/latest/userguide/setting-up.html>) to create the EKS cluster. Here's an example command:

Bash
~~~
eksctl create cluster \
  --name my-eks-cluster \
  --version 1.23  # Specify desired Kubernetes version
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/eks-cluster-role  # Replace with your IAM role ARN
  --nodegroup-name my-nodegroup \
  --nodes 2  # Number of worker nodes
  --node-type t3.medium  # Instance type for worker nodes
  --vpc <VPC_ID>  # Replace with your VPC ID
  --subnets <SUBNET_ID1>,<SUBNET_ID2>  # Replace with subnet IDs from your VPC
  --region <REGION>  # Replace with your AWS region
~~~

**2\. Configuring YAML files for Deployment:**

Create YAML files for your application deployment and service:

**2.1 Deployment YAML** (example-deployment.yaml):

YAML
~~~
apiVersion: apps/v1 # Kubernetes API version for deployments
kind: Deployment # Kind of resource we're defining
metadata:
  name: hello-world # Name of our deployment
spec:
  replicas: 1 # Number of pods (application instances) to run
  selector: # Selector for pods that belong to this deployment
    matchLabels:
      app: hello-world # Label to identify pods
  template: # Pod template for our deployment
    metadata:
      labels: # Labels for the pods
        app: hello-world
    spec:
      containers: # Container definition within the pod
      - name: hello-world # Name of the container
        image: nginx:latest # Docker image to use (pre-built Nginx server)
        ports: # Ports exposed by the container
        - containerPort: 80 # Expose container port 80
~~~

**2.2 Service YAML (**hello-world-service.yaml**):**

YAML
~~~
apiVersion: v1 # Kubernetes API version for services
kind: Service # Kind of resource we're defining
metadata:
  name: hello-world-service # Name of our service
spec:
  selector: # Selector for pods to route traffic to
    app: hello-world # Matches pods with the label `app: hello-world`
  type: LoadBalancer # Service type (can be changed to NodePort for internal access)
  ports: # Ports exposed by the service
  - port: 80 # Service port (matches container port)
    targetPort: 80 # Target port on the pods
~~~

**Applying the YAML Files:**

1\.	Open a terminal window.

2\.	Navigate to the directory where you saved your YAML files (e.g., example-deployment.yaml and hello-world-service.yaml).

3\.	Use the following command to apply each YAML file separately:
Bash
~~~
kubectl apply -f <filename.yaml>
~~~
**Applying Multiple Files:**
You can apply multiple YAML files sequentially using the same command:
Bash
~~~
kubectl apply -f example-deployment.yaml -f hello-world-service.yaml
~~~

**3\. Deploying the Application and Service:**

After applying the YAML files, wait a few minutes for your pods and service to become ready. You can monitor the process using:

Bash
~~~
kubectl get pods
kubectl get services
~~~

These commands will show you the status of your deployment and service. Look for the pods to be in a "Running" state and the service to be in an "ExternalTrafficPending" state (if using LoadBalancer).

**4\. Accessing the Application:**

- **LoadBalancer Service:**
  - Once the service transitions to a "LoadBalancer" state, you'll see the DNS name assigned to your service in the kubectl get services output.
  - Open this DNS name in a web browser to access your application running on the Kubernetes cluster.
- **NodePort Service:**
  - If you configured a NodePort service, identify the worker node IP addresses using the AWS Management Console or kubectl get nodes.
  - Combine the Node IP address with the NodePort specified in your service YAML file (e.g., &lt;Node IP&gt;:&lt;NodePort&gt;). This is the URL to access your application from outside the cluster.

**5\. Autoscaling and Load Balancing:**

**5.1 Horizontal Pod Autoscaler (HPA):**
~~~
apiVersion: autoscaling/v2beta2 # Kubernetes API version for HPAs
kind: HorizontalPodAutoscaler # Kind of resource we're defining
metadata:
  name: hello-world-hpa # Name of our HPA
spec:
  scaleTargetRef: # Reference to the deployment to scale
    apiVersion: apps/v1
    kind: Deployment
    name: hello-world
  minReplicas: 1 # Minimum number of replicas allowed
  maxReplicas: 5 # Maximum number of replicas allowed
  metrics: # Metrics to monitor for scaling
  - type: Resource # Metric type
    resource:
      name: cpu # Monitor CPU usage
      target: # Target utilization for the metric
        type: Utilization
        averageUtilization: 80 # Scale up if CPU usage exceeds 80%
~~~

**5.2 Deploying HPA:**

Use kubectl apply -f hello-world-hpa.yaml to create the HPA object. Now, the HPA will automatically scale the hello-world deployment based on CPU usage.

**5.3 Load Balancer:**

The service you created earlier distributes traffic across all available pods in the deployment. This ensures your application can handle fluctuating traffic volumes even as the number of pods changes due to autoscaling.

**6\. Service Registration:**

Pods in a Kubernetes cluster have unique IP addresses that can change dynamically. Services act as a virtual IP address and service registry, providing a stable DNS name for your application. Pods within the cluster use this service name to discover and communicate with your application.

**Demo:**

1. You can now simulate traffic spikes (e.g., using a load testing tool) and observe the HPA automatically scaling the deployment up by creating additional pods.
2. The service continues to distribute traffic across all pods, ensuring application responsiveness.

**Cleaning Up:**

When you're finished, you can delete your resources using kubectl delete:

Bash
~~~
kubectl delete deployment hello-world
kubectl delete service hello-world-service
kubectl delete hpa hello-world-hpa # If you created an HPA
~~~

Finally, you can delete the EKS cluster using eksctl delete cluster my-eks-cluster. Remember to clean up any associated AWS resources like VPCs and subnets if you created them specifically for this project.
