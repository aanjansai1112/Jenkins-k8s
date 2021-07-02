#!/bin/bash

echo "Select the options to deploy the services"
echo " "

PS3="Select the operation: "

select opt in Namespace RBAC PVC Jenkins_service Ilb_jenkins_service Webhook_secret Jenkins_deployment Quit; do

  case $opt in
    Namespace)
      echo "********Namespace******"
      kubectl apply -f ./namepace.yml -n jenkins 
      echo " "
      ;;
    RBAC)
      echo "********RBAC******"
      kubectl apply -f ./rbac.yml -n jenkins 
      echo " "
      ;;
    PVC)
      echo "********PVC******"
      kubectl apply -f ./pv-volumes.yml -n jenkins 
      echo " "
      ;;
    Jenkins_service)
      echo "********Jenkins_service******"
      kubectl apply -f ./jenkins-svc.yml -n jenkins 
      echo " "
      ;;
    Ilb_jenkins_service)
      echo "********Ilb_jenkins_service******"
      kubectl apply -f ./ilb-jenkins-svc.yml -n jenkins 
      echo " "
      ;;
    Webhook_secret)
      echo "********Webhook_secret******"
      kubectl apply -f ./webhookrelay-credentials.yml -n jenkins
      echo " "
      ;; 
    Jenkins_deployment)
      echo "********Jenkins_deployment******"
      kubectl apply -f ./jenkins-deploy.yml -n jenkins 
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

