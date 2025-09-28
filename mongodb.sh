#! /bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0269c42f363b9217b"
Hosted_zone_ID="Z02845132921NLJI9M7EG"
Domain="devsecops86s.space"
instance_name=$1
instance_id=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" --query 'Instances[0].InstanceId' --output text)
instance_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
record_name=$instance_name.$Domain
echo "successfully created $instance_name server : $instance_ip"
sudo cp mongo.repo /etc/yum.repos.d/
if [ $? -eq 0 ]; then
    sudo dnf install mongodb-org -y
fi
sudo systemctl enable mongod
sudo systemctl start mongod 



