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

sai@Quantiphi-2375:~$ gcloud compute addresses list --project demo-project                                                                                                  NAME             ADDRESS/RANGE  TYPE      PURPOSE       NETWORK  REGION       SUBNET                            STATUS                                                      jenkins-ilb-gke  10.10.*.*     INTERNAL  GCE_ENDPOINT           us-central1  test_subnet                        IN_USE

Use the generated IP address in the ilb-jenkins-svc.yml

loadBalancerIP: <IP_address>
(Example : loadBalancerIP: 10.10.*.*)
 
