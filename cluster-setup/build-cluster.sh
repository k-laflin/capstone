#set variables
export $AWS_REGION='us-west-2'
export $ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

#******************#
#eks cluster
#******************#
#go to folder
cd cluster-setup

#create cluster
eksctl create cluster -f capstone-cluster.yml

#******************#
#load balancer
#******************#
cd manifests/alb-controller

#create OIDC identity controller
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster capstone \
    --approve

eksctl create iamserviceaccount \
    --cluster capstone \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

#install cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

#create load balancer
kubectl apply -f v2_2_1_full.yaml

#******************#
#deploy microservice
#******************#
#go to manifest folder
cd ~/cluster-setup/manifests

#deploy app
kubectl apply -f deploy-app.yml
kubectl apply -f service-app.yml
kubectl apply -f ingress.yml


