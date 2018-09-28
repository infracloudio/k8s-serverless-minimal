#!/bin/bash
# TODO: Implement undeploy aswell

#appName=`echo ${PWD##*/}`
appName='nginx'
imageName='nginx:latest'
undeploy=`printenv KUBECTL_PLUGINS_LOCAL_FLAG_UNDEPLOY`

echo "undeploy flag: ${undeploy}"
# Create k8s deployment
sed  "s/NAME/${appName}/g" deployment.yaml > dep_temp.yaml
sed  "s/IMAGE/${imageName}/g" dep_temp.yaml > dep_temp1.yaml

# Create k8s service
sed  "s/NAME/${appName}/g" service.yaml > svc_temp.yaml

if [[ "$undeploy" != "false" ]]; then
	kubectl delete -f dep_temp1.yaml
	kubectl delete -f svc_temp.yaml
else
	kubectl apply -f dep_temp1.yaml
	kubectl apply -f svc_temp.yaml

	sleep 10
	ip=`kubectl get svc | grep ${appName} | awk '{print $4}'`
	port=`kubectl get svc | grep ${appName} | awk '{print $5}' | awk -F ':' '{print $1}'`
	echo "Your app is available at ${ip}:${port}"
fi

