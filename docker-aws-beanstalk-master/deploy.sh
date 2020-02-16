#!/bin/bash
# usage: ./deploy.sh master

NOW=`date +%s`

BRANCH=$1
SHA1=`echo -n $NOW | openssl dgst -sha1 |awk '{print $NF}'`

[[ -z "$BRANCH" ]] && { echo "must pass a branch param" ; exit 1; }

AWS_ACCOUNT_NUBMER=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId`

# Main variables to modify for your account
AWS_ACCOUNT_ID=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId`
EB_APP_NAME='demo-docker-cicd'
EB_ENV_NAME='demo-docker-cicd-test'
EB_BUCKET='demo-docker-cicd-deployments'
REGION='us-east-1'

VERSION=$BRANCH-$SHA1
ZIP=$VERSION.zip

aws configure set default.region $REGION

# Authenticate against our Docker registry
eval $(aws ecr get-login --no-include-email)

# Build and push the image
docker build -t $EB_APP_NAME:$VERSION .
docker tag $EB_APP_NAME:$VERSION $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$EB_APP_NAME:$VERSION
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$EB_APP_NAME:$VERSION


# Replace variables in the Dockerrun file before zipping
cp dockerrun.aws.template Dockerrun.aws.json
sed -i='' "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json
sed -i='' "s/<EB_APP_NAME>/$EB_APP_NAME/" Dockerrun.aws.json
sed -i='' "s/<TAG>/$VERSION/" Dockerrun.aws.json



#cat Dockerrun.aws.json | python -m json.tool

# Zip up the Dockerrun file
zip -r $ZIP Dockerrun.aws.json

# Push file to s3
aws s3 cp $ZIP s3://$EB_BUCKET/$ZIP

# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name $EB_APP_NAME \
    --version-label $VERSION --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP

# Update the environment to use the new application version
aws elasticbeanstalk update-environment --environment-name $EB_ENV_NAME \
      --version-label $VERSION

deploystart=$(date +%s)
timeout=3000 # Seconds to wait before error. If it's taking awhile - your boxes probably are too small.
threshhold=$((deploystart + timeout))
while true; do
    # Check for timeout
    timenow=$(date +%s)
    if [[ "$timenow" > "$threshhold" ]]; then
        echo "Timeout - $timeout seconds elapsed"
        exit 1
    fi

    # See what's deployed
    current_version=`aws elasticbeanstalk describe-environments --application-name "$EB_APP_NAME" --environment-name "$EB_ENV_NAME" --query "Environments[*].VersionLabel" --output text`

    status=`aws elasticbeanstalk describe-environments --application-name "$EB_APP_NAME" --environment-name "$EB_ENV_NAME" --query "Environments[*].Status" --output text`

    if [ "$current_version" != "$VERSION" ]; then
        echo "Tag not updated (currently $version). Waiting."
        sleep 10
        continue
    fi
    if [ "$status" != "Ready" ]; then
        echo "System not Ready -it's $status. Waiting."
        sleep 10
        continue
    fi
    break
done

# Cleanup

#rm Dockerrun.aws.json
#rm Dockerrun.aws.json=
#rm $ZIP
