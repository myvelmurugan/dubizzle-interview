# dubizzle-interview
Dubizzle Assesment

Tools / ClI required
1)	aws cli
2)	helm
3)	aws-iam-authenticator
4)	terraform

git@github.com:myvelmurugan/dubizzle-interview.git  -- > download this repo


oot@ip-172-31-33-111 interview-dubizzle]# ls
cluster-autoscaler  efk  helm-appdeployment  hpa  Ingress-controller  k8s-appdeployment  README.md  terraform

-	terraform – to provision the eks cluster
-	cluster-autoscaler – to deploy cluster autoscaler
-	Ingress-controller – to create ingress-controller
-	K8s-appdeployment – to create web application 
-	Helm-appdeployment –web application with fluentd 
-	Hpa – to create metric server for hpa


Using Terraform provisioned EKS cluster with nodegroups 
1)	Spot instance with asg
2)	Ondeman instance with asg


Also create OIDC provider and required policy for the clusterautoscaler deployment in terraform.
$ terraform init
$ terraform plan
$ terraform apply   - below is the terraform state list
 
 

Once created the cluster, Install cluster autoscaler deployment and service account, Already OIDC provide service account mapping has done through terraform
https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html - refernce
cd /<gitrepo>/cluster-autoscaler 
 run – kubectl create –f cluster-autoscaler.yaml -> you can edit the cluster name as per the terraform state.
 

Application deployment 
-	Docker Image : vel123/nginx:2.0
-	Config map for nginx configuration and fluentd config
-	Fluentd side car container for shipping the nginx logs


kubectl create -f <gitpath>/k8sappdeployment/*.yaml

Helm also we can deploy
 ex helm install dubizzle ./dubizzle-assesment/ -f dubizzle-assesment/values.yaml  -n vel

[root@ip-172-31-33-111 k8s-appdeployment]# kubectl get deploy nginx-dep -o yaml | grep -i image
      - image: vel123/nginx:2.0
        imagePullPolicy: Always
        image: k8s.gcr.io/fluentd-gcp:1.30
        imagePullPolicy: IfNotPresent

 
ELK Helm
Helm install elasticsearch  <gitpath>efk/elasticsearch 
Helm install kibana <gitpath/efk/kibana
Kubectl create –f <gitpath>/fluentd*/yaml

