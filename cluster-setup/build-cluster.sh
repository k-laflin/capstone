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


# 'apiVersion: v1
#   6 data:
#   7   mapUsers: |
#   8     - userarn: arn:aws:iam::466390023253:user/Admin
#   9       username: admin
#  10       groups: 
#  11         - system:masters
#  12   mapRoles: |
#  13     - groups:
#  14       - system:bootstrappers
#  15       - system:nodes
#  16       rolearn: arn:aws:iam::466390023253:role/eksctl-capstone-nodegroup-capston-NodeInstanceRole-EPCVKJT724SC
#  17       username: system:node:{{EC2PrivateDNSName}}
#  18 kind: ConfigMap
#  19 metadata:
#  20   creationTimestamp: "2021-12-08T19:53:20Z"
#  21   name: aws-auth
#  22   namespace: kube-system
#  23   resourceVersion: "1420"
#  24   uid: 52baa22a-d3f5-4144-bb50-59127cad79c0'