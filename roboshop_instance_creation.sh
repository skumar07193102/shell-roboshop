#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0269c42f363b9217b"
Hosted_zone_ID="Z02845132921NLJI9M7EG"
Domain="devsecops86s.space"
for instance in $@
do
    instance_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $instance_ID--query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        record_name=$instance.$Domain
    else
        IP=$(aws ec2 describe-instances --instance-ids $instance_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        record_name=$Domain
    fi
    echo "$instance_ID"
    echo "$instance : $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $Hosted_zone_ID \
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
    }
    '
done