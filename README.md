# Jenkins-k8s

Create a static IP in the same region as your GKE cluster. The subnet must be the same subnet that the load balancer uses, which by default is the same subnet that is used by the GKE cluster node IPs.

If your cluster is in a Shared VPC service project but uses a Shared VPC network in a host project:

gcloud compute addresses create IP_ADDR_NAME \
--project SERVICE_PROJECT_ID \
--subnet projects/HOST_PROJECT_ID/regions/REGION/subnetworks/SUBNET \
--region=REGION


If your cluster and the VPC network are in the same project:

gcloud compute addresses create IP_ADDR_NAME \
    --project PROJECT_ID \
    --subnet SUBNET \
    --region REGION

$ gcloud compute addresses list --project demo-project                                                                                                 
NAME        ADDRESS/RANGE    TYPE    PURPOSE    NETWORK    REGION    SUBNET    STATUS
jenkins-ilb-gke  10.10.#.#  INTERNAL  GCE_ENDPOINT    us-central1  test_subnet  IN_USE

Use the generated IP address in the ilb-jenkins-svc.yml

loadBalancerIP: <IP_address>
(Example : loadBalancerIP: 10.10.#.#)
 
How to use the scripts.

Clone the github repo.
Command: $ git clone https://github.com/aanjansai1112/Jenkins-k8s.git

Cloned repo will have the following folder structure.

Folder Structure:
Jenkins-k8s (folder)
    |
     apply_script.sh
    |
     delete_script.sh
    |
     ilb-jenkins-svc.yml
    |
     jenkins-deploy.yml
    |
     jenkins-svc.yml 
    |
     namepace.yml 
    |
     pv-volumes.yml 
    |
     rbac.yml

RBAC:
RBAC authorization uses the rbac.authorization.k8s.io API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API.
File: rbac.yml

Namespace:
Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called namespaces.
File: namespace.yml

PVC:
A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., they can be mounted ReadWriteOnce, ReadOnlyMany or ReadWriteMany, see AccessModes).
File: pv-volumes.yml

Service:
A Kubernetes service is a logical abstraction for a deployed group of pods in a cluster (which all perform the same function).
Since pods are ephemeral, a service enables a group of pods, which provide specific functions (web services, image processing, etc.) to be assigned a name and unique IP address (clusterIP). As long as the service is running that IP address, it will not change. Services also define policies for their access.
File: jenkins-svc.yml

Note: If user want to use the static private ip for the loadbalancing then user must use the recommended service file.
File: ilb-jenkins-svc.yml

To generate the static private ip then please apply the command mentioned at the starting of the document.

Deployment:
In Kubernetes, a deployment is a method of launching a pod with containerized applications and ensuring that the necessary number of replicas is always running on the cluster.
File: jenkins-deploy.yml

Deployment process:
Now apply the files to run the jenkins server.
Before that make sure you are connected to the GKE cluster, if not then execute the following command from the server (where you gonna access the GKE cluster) to connect the cluster.
$ gcloud container clusters get-credentials <cluster_name> --zone <zone> --project <project_id>

Note: Make sure kubectl is installed on the server where you gonna deploy the jenkins.

Once the GKE cluster is connected and have the kubectl client then execute the following script.
Check whether apply_script.sh and delete_script.sh files are executable files are not, if not then make them as executable files.
$ chmod +x apply_script.sh delete_script.sh

Now apply the script to deploy the jenkins in GKE cluster.
$ ./apply_script.sh

It will prompt the options to select.

Select the options to deploy the services

1) Namespace
2) RBAC
3) PVC
4) Jenkins_service
5) Ilb_jenkins_service
6) Jenkins_deployment
7) Quit
Select the operation:

Note: If user is deploying it for the first time then follow the given order.
Order: 1, 2, 3, (4/5) are the user choice(either 4 or 5), 6, 7 (for Quit).

Once the deployment is done, check whether services are applied or not.

$ kubectl get ns
NAME              STATUS   AGE
default           Active   3d19h
jenkins           Active   3d5h
kube-node-lease   Active   3d19h
kube-public       Active   3d19h
kube-system       Active   3d19h

$ kubectl get sa -n jenkins
NAME            SECRETS   AGE
default         1         3d5h
jenkins-admin   1         3d4h

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                      STORAGECLASS      REASON   AGE
pvc-894de279-a1dd-4392-b28f-8a0f69a24b46   10Gi       RWO            Retain           Bound       jenkins/jenkins-pv-claim   jenkins                    3d4h

$ kubectl get pvc -n jenkins
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
jenkins-pv-claim   Bound    pvc-894de279-a1dd-4392-b28f-8a0f69a24b46   10Gi       RWO            jenkins        3d4h

$ kubectl get svc -n jenkins
NAME           TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
jenkins        LoadBalancer   10.1.#.#     10.10.#.#     8080:31461/TCP   45h
jenkins-jnlp   ClusterIP      10.1.#.#     <none>        50000/TCP        45h

Note: Here user used the internal loadbalancer to access jenkins inside the private network.

$ kubectl get deploy -n jenkins
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
jenkins   1/1     1            1           3d4h

$ kubectl get pods -n jenkins
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-55955b7fc7-n5k5h   1/1     Running   0          3d4h

Jenkins server is up and running, to get the secret token for the jenkins then check the logs of the jenkins pod.

$ kubectl logs jenkins-55955b7fc7-n5k5h  -f -n jenkins
Running from: /usr/share/jenkins/jenkins.war
webroot: EnvVars.masterEnvVars.get("JENKINS_HOME")
2021-06-26 08:13:53.075+0000 [id=1]     INFO    org.eclipse.jetty.util.log.Log#initialized: Logging initialized @1057ms to org.eclipse.jetty.util.log.JavaUtilLog
2021-06-26 08:13:53.320+0000 [id=1]     INFO    winstone.Logger#logInternal: Beginning extraction from war file
2021-06-26 08:13:55.368+0000 [id=1]     WARNING o.e.j.s.handler.ContextHandler#setContextPath: Empty contextPath
2021-06-26 08:13:55.495+0000 [id=1]     INFO    org.eclipse.jetty.server.Server#doStart: jetty-9.4.39.v20210325; built: 2021-03-25T14:42:11.471Z; git: 9fc7ca5a922f2a37b84ec9dbc26a5168cee7e667; jvm 1.8.0_292-b10
2021-06-26 08:13:55.996+0000 [id=1]     INFO    o.e.j.w.StandardDescriptorProcessor#visitServlet: NO JSP Support for /, did not find org.eclipse.jetty.jsp.JettyJspServlet
2021-06-26 08:13:56.098+0000 [id=1]     INFO    o.e.j.s.s.DefaultSessionIdManager#doStart: DefaultSessionIdManager workerName=node0
2021-06-26 08:13:56.102+0000 [id=1]     INFO    o.e.j.s.s.DefaultSessionIdManager#doStart: No SessionScavenger set, using defaults
2021-06-26 08:13:56.105+0000 [id=1]     INFO    o.e.j.server.session.HouseKeeper#startScavenging: node0 Scavenging every 600000ms
2021-06-26 08:13:57.114+0000 [id=1]     INFO    hudson.WebAppMain#contextInitialized: Jenkins home directory: /var/jenkins_home found at: EnvVars.masterEnvVars.get("JENKINS_HOME")
2021-06-26 08:13:57.428+0000 [id=1]     INFO    o.e.j.s.handler.ContextHandler#doStart: Started w.@4362d7df{Jenkins v2.289.1,/,file:///var/jenkins_home/war/,AVAILABLE}{/var/jenkins_home/war}
2021-06-26 08:13:57.481+0000 [id=1]     INFO    o.e.j.server.AbstractConnector#doStart: Started ServerConnector@28cda624{HTTP/1.1, (http/1.1)}{0.0.0.0:8080}
2021-06-26 08:13:57.483+0000 [id=1]     INFO    org.eclipse.jetty.server.Server#doStart: Started @5465ms
2021-06-26 08:13:57.487+0000 [id=21]    INFO    winstone.Logger#logInternal: Winstone Servlet Engine running: controlPort=disabled
2021-06-26 08:14:00.129+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: Started initialization
2021-06-26 08:14:00.195+0000 [id=26]    INFO    jenkins.InitReactorRunner$1#onAttained: Listed all plugins
2021-06-26 08:14:03.103+0000 [id=26]    INFO    jenkins.InitReactorRunner$1#onAttained: Prepared all plugins
2021-06-26 08:14:03.109+0000 [id=26]    INFO    jenkins.InitReactorRunner$1#onAttained: Started all plugins
2021-06-26 08:14:03.158+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: Augmented all extensions
2021-06-26 08:14:06.141+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: System config loaded
2021-06-26 08:14:06.142+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: System config adapted
2021-06-26 08:14:06.142+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: Loaded all jobs
2021-06-26 08:14:06.143+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: Configuration for all jobs updated
2021-06-26 08:14:06.911+0000 [id=40]    INFO    hudson.model.AsyncPeriodicWork#lambda$doRun$0: Started Download metadata
2021-06-26 08:14:06.936+0000 [id=40]    INFO    hudson.util.Retrier#start: Attempt #1 to do the action check updates server
2021-06-26 08:14:07.448+0000 [id=26]    INFO    jenkins.install.SetupWizard#init:

*************************************************************
*************************************************************
*************************************************************

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

###############################

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

*************************************************************
*************************************************************
*************************************************************

2021-06-26 08:14:35.625+0000 [id=27]    INFO    jenkins.InitReactorRunner$1#onAttained: Completed initialization
2021-06-26 08:14:35.653+0000 [id=20]    INFO    hudson.WebAppMain$3#run: Jenkins is fully up and running

Copy the generated password (Ex: ###############################)

Access the jenkins UI (GKE private cluster with private endpoints)
step 1. Open the cloud shell.

step 2. Execute the following command to ssh into the server present in the same subnet where GKE cluster is created.
(ex: gcloud beta compute ssh --zone "<zone>" "<server_name>"  --tunnel-through-iap --project "<project_name>" -- -L8088:localhost:8089)

Here, we are port forward sever to cloud shell.
8088 is the cloud shell port number.
8089 is the server port number.

Once user ssh into the server, then connect the GKE cluster using gcloud command.
(ex: gcloud container clusters get-credentials <cluster_name> --zone <zone> --project <project_id>)

Now, port forward the jenkins service port to the server.
$ kubectl port-forward service/jenkins 8089:8080 -n jenkins

Here,
8089 is the server port number.
8080 is the jenkins service port number.

Now, in the cloud shell click on the web preview and change the port number to 8088 and click on change and preview.
(web preview --> change port --> enter 8088 --> change and preview).

It will open up the jenkins UI.

Delete the resources.

To delete the resources, execute the following command.
$ ./delete_script.sh

It will prompt options to delete the resources.
Select the options to delete the services

1) Namespace
2) RBAC
3) PVC
4) Jenkins_service
5) Ilb_jenkins_service
6) Jenkins_deployment
7) Quit
Select the operation:

Enter the valid option to delete the resources.
