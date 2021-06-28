#!/bin/bash

echo "Select the options to delete the services"
echo " "

PS3="Select the operation: "

select opt in Namespace RBAC PVC Jenkins_service Ilb_jenkins_service Jenkins_deployment Quit; do

  case $opt in
    Namespace)
      echo "********Namespace******"
      kubectl delete -f ./namepace.yml -n jenkins 
      echo " "
      ;;
    RBAC)
      echo "********RBAC******"
      kubectl delete -f ./rbac.yml -n jenkins 
      echo " "
      ;;
    PVC)
      echo "********PVC******"
      kubectl delete -f ./pv-volumes.yml -n jenkins 
      echo " "
      ;;
    Jenkins_service)
      echo "********Jenkins_service******"
      kubectl delete -f ./jenkins-svc.yml -n jenkins 
      echo " "
      ;;
    Ilb_jenkins_service)
      echo "********Ilb_jenkins_service******"
      kubectl delete -f ./ilb-jenkins-svc.yml -n jenkins 
      echo " "
      ;;
    Jenkins_deployment)
      echo "********Jenkins_deployment******"
      kubectl delete -f ./jenkins-deploy.yml -n jenkins 
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

