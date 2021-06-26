#!/bin/bash

echo "Select the options in increasing order"
echo " "

PS3="Select the operation: "

select opt in Namespace RBAC PVC Jenkins_service Jenkins_deployment Quit; do

  case $opt in
    Namespace)
      echo "********Namespace******"
      kubectl apply -f jenkins-k8s/namepace.yml -n jenkins 
      echo " "
      ;;
    RBAC)
      echo "********RBAC******"
      kubectl apply -f jenkins-k8s/rbac.yml -n jenkins 
      echo " "
      ;;
    PVC)
      echo "********PVC******"
      kubectl apply -f jenkins-k8s/pv-volumes.yml -n jenkins 
      echo " "
      ;;
    Jenkins_service)
      echo "********Jenkins_service******"
      kubectl apply -f jenkins-k8s/jenkins-svc.yml -n jenkins 
      echo " "
      ;;
    Jenkins_deployment)
      echo "********Jenkins_deployment******"
      kubectl apply -f jenkins-k8s/jenkins-deploy.yml -n jenkins 
      echo " "
      ;;
    Quit)
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done

