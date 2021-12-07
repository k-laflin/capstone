cat <<\EOF>> ~/.bashrc

#function to add two floating nums
add() { n="$@"; bc <<< "${n// /+}"; }

#get most recent capstone version as a number
export VERSION=$(aws ecr describe-images --repository-name capstone \
--query 'sort_by(imageDetails,& imagePushedAt)[*].imageTags' --output text | xargs -n1 | sort | xargs | rev | cut -d" " -f1 | rev | tr -d v)
#index version automatically 
export INDEX_VERSION=$(add $VERSION 0.1)
#create new version 
export NEW_VERSION=$(printf "v%.1f\n" $INDEX_VERSION)
EOF