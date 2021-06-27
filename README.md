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
