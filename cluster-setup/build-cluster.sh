#set variables
export AWS_REGION='us-west-2'
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

#******************#
#eks cluster
#******************#
#go to folder
ls

#create cluster
echo 'creating capstone cluster'
eksctl create cluster -f capstone-cluster.yml

#******************#
#load balancer
#******************#
cd manifests/alb-controller

#create OIDC identity controller
echo 'creating iam oidc provider'
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster capstone \
    --approve

echo 'creating iam service account'
eksctl create iamserviceaccount \
    --cluster capstone \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

#install cert-manager
echo 'installing cert-manager'
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

#create load balancer
echo 'create load balancer'
kubectl apply -f v2_2_1_full.yaml

#******************#
#deploy microservice
#******************#
#go to manifest folder
cd ..
ls

#deploy app
echo 'deploy app'
kubectl apply -f deploy-app.yml
kubectl apply -f service-app.yml
kubectl apply -f ingress.yml

#  kubectl edit configmap aws-auth -n kube-system

#   apiVersion: v1
#   data:
#     mapUsers: |
#       - userarn: arn:aws:iam::466390023253:user/Admin
#         username: admin
#         groups: 
#           - system:masters
#     mapRoles: |
#       - groups:
#         - system:bootstrappers
#         - system:nodes
#         rolearn: arn:aws:iam::466390023253:role/eksctl-capstone-nodegroup-capston-NodeInstanceRole-EPCVKJT724SC
#         username: system:node:{{EC2PrivateDNSName}}
#   kind: ConfigMap
#   metadata:
#     creationTimestamp: "2021-12-08T19:53:20Z"
#     name: aws-auth
#     namespace: kube-system
#     resourceVersion: "1420"
#     uid: 52baa22a-d3f5-4144-bb50-59127cad79c0