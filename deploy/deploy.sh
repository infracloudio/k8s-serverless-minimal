#!/bin/bash

undeploy=`printenv KUBECTL_PLUGINS_LOCAL_FLAG_UNDEPLOY`
appdir=`printenv KUBECTL_PLUGINS_LOCAL_FLAG_APPDIR`

echo "undeploy flag: ${undeploy}"

if test -z "$appdir"; then
	echo "appdir CLI param not specified"
        kubectl plugin deploy -h
	exit 2
fi

appName=`echo ${appdir##*/}`
imageName=${appName}':latest'
projectId='logical-bloom-190911'
imageDestination='gcr.io\/'${projectId}'\/'${imageName}
appConfigMap=${appName}-config

# Create k8s deployment
sed  "s/NAME/${appName}/g" deployment.yaml > dep_temp.yaml
sed  -i "s/IMAGE/${imageName}/g" dep_temp.yaml

# Create kaniko deployment
sed  "s/IMAGEDESTINATION/${imageDestination}/g" kaniko.yaml > kaniko_temp.yaml
sed  -i "s/APPCONFIGMAP/${appConfigMap}/g" kaniko_temp.yaml

# Create k8s service
sed  "s/NAME/${appName}/g" service.yaml > svc_temp.yaml

if [[ "$undeploy" != "false" ]]; then
       kubectl delete configmap ${appConfigMap}
       kubectl delete -f kaniko_temp.yaml
       kubectl delete -f dep_temp.yaml
       kubectl delete -f svc_temp.yaml
else
       kubectl delete configmap ${appConfigMap}
       kubectl create secret generic kaniko-secret --from-file=kaniko-secret.json
       kubectl create configmap ${appConfigMap} --from-file=${appdir}
       kubectl apply -f kaniko_temp.yaml
       kubectl apply -f dep_temp.yaml
       kubectl apply -f svc_temp.yaml

	sleep 10
	ip=`kubectl get svc | grep ${appName} | awk '{print $4}'`
	port=`kubectl get svc | grep ${appName} | awk '{print $5}' | awk -F ':' '{print $1}'`
	echo "Your app is available at ${ip}:${port}"
fi
