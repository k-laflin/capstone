<<comment
    blue/green switch code inspired by:

    Author: Nithin Mallya
    Title: Using CircleCI and Kubernetes to achieve seamless deployments to Google Container Engine
    URL: https://medium.com/google-cloud/using-circleci-and-kubernetes-to-achieve-seamless-deployments-to-google-container-engine-8b26abc04846
comment

kubectl describe service capstone > capstone.txt 

#set credentials 
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_URL

#get most recent version pushed to capstone ecr 
export VERSION=$(aws ecr describe-images --repository-name capstone \
--query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' --output text)

#get version as a number
export N=$(aws ecr describe-images --repository-name capstone \
--query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' --output text | tr -d v)
#index version automatically 
export NEW=$(($N + 0.1))
export NEW_VERSION=$(printf "v%.1f \n" $NEW)
echo new version is $NEW_VERSION

echo $VERSION

#get url hosting all of the ECR repositories 
export ECR_URL=$(aws ecr describe-repositories --repository-names capstone \
--query 'repositories[0].repositoryUri' | tr -d '"' | cut -d/ -f1)


if grep -q 'color=blue' capstone.txt:
then
    echo "current is blue"
    echo "switching to green"
    export COLOR='green'

    # #deploy most recent capstone image to capstone-green
    # docker pull $ECR_URL/capstone:$VERSION
    # docker tag $ECR_URL/capstone:$VERSION $ECR_URL/capstone-green:latest

    # #update image in deployment
    # kubectl set image deployment/capstone-green capstone=466390023253.dkr.ecr.us-west-2.amazonaws.com/capstone-green:latest
else
    echo "current is green"
    echo "switching to blue"
    export COLOR='blue'
fi

#deploy most recent capstone image to capstone-green
docker pull $ECR_URL/capstone:$VERSION
docker tag $ECR_URL/capstone:$VERSION "${ECR_URL}/capstone-${COLOR}:latest"
docker push "${ECR_URL}/capstone-${COLOR}:latest"

#update image in deployment
#kubectl set image deployment/capstone-$COLOR capstone=466390023253.dkr.ecr.us-west-2.amazonaws.com/capstone-$COLOR:latest