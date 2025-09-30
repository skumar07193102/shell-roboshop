#!/bin/bash
AMI_NAME="RHEL-9-DevOps-Practice"
SG="sg-0d7af0cacff646e77"
instance_type="t3.micro"
host_zone_id="Z02845132921NLJI9M7EG"
Domain=devsecops86s.space
for instance in $@
do
     instance_id=$(aws ec2 run-instances \
    --image-id $AMI_NAME \
    --instance-type $instance_type \
    --security-group-ids $SG \
    --tag-specifications "'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]'")
if[ $instance != frontend ]; then
    IP=$(aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query 'Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress}' \
    --output text)
    servername=$instance
    record_name=$instance.$Domain
else 
    IP=$(aws ec2 describe-instances \
    --instance-ids $instance-id \
    --query 'Reservations[*].Instances[*].{PublicIP:PublicIpAddress}' \
    --output text)
    servername=$instance
    record_name=$Domain
fi
done
echo  "$instance($instance_id) : $IP"
aws route53 change-resource-record-sets \
    --hosted-zone-id $host_zone_id \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$record_name'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]

username=ec2-user
ssh $username@$IP
read password
echo "enter the password"
User=$(id -u)
echo " logged in as $User"