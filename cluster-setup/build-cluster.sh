#set variables
export AWS_REGION='us-west-2'
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export RED='\033[0;31m'
export NOCOLOR='\033[0m'


#******************#
#save ids
#******************#
export VPC_ID=$(aws cloudformation describe-stacks --stack-name capstone-network --query "Stacks[0].Outputs[?OutputKey=='VPC'].OutputValue" --output text)
export SN_2A_ID=$(aws cloudformation describe-stacks --stack-name capstone-network --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1'].OutputValue" --output text)
export SN_2B_ID=$(aws cloudformation describe-stacks --stack-name capstone-network --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2'].OutputValue" --output text)
export SN_2C_ID=$(aws cloudformation describe-stacks --stack-name capstone-network --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet3'].OutputValue" --output text)

#******************#
#eks cluster
#******************#
#go to folder
ls

echo "${RED} updating capstone-cluster.yml ${NOCOLOR}"

#add vpc config
cat << EOF >> capstone-cluster.yml
vpc:
  id: $VPC_ID
  subnets: 
    public: 
      us-west-2a:
        id: $SN_2A_ID
      us-west-2b:
        id: $SN_2B_ID
      us-west-2c:
        id: $SN_2C_ID
EOF

cat capstone-cluster.yml

#create cluster
echo "${RED}creating capstone cluster${NOCOLOR}"
eksctl create cluster -f capstone-cluster.yml

#******************#
#load balancer
#******************#
cd manifests/alb-controller

#create OIDC identity controller
echo "${RED}creating iam oidc provider${NOCOLOR}"
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster capstone \
    --approve

echo "${RED}creating iam service account${NOCOLOR}"
eksctl create iamserviceaccount \
    --cluster capstone \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

#install cert-manager
echo "${RED}installing cert-manager${NOCOLOR}"
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

sleep 30

#create load balancer
echo "${RED}create load balancer${NOCOLOR}"
kubectl apply -f v2_2_1_full.yaml

sleep 30

#******************#
#deploy microservice
#******************#
#go to manifest folder
cd ..
ls

#deploy app
echo "${RED}deploy app${NOCOLOR}"
kubectl apply -f deploy-app.yml
kubectl apply -f service-app.yml
kubectl apply -f ingress.yml


