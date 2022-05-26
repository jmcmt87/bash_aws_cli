#! /bin/bash
# Author: Jorge Marcos Martos

queue_url=$(aws sqs list-queues --query QueueUrls[0])
queue_url="${queue_url%\"}"
queue_url="${queue_url#\"}"


ami_id="ami-02d1f8db964df5386"


function check_messages () {
	queue_check=$(aws sqs get-queue-attributes --queue-url $queue_url \
         --attribute-names ApproximateNumberOfMessages)
	number_messages=$(echo $queue_check | jq -r  '.Attributes.ApproximateNumberOfMessages')
}

function launch_instance () {
	aws ec2 run-instances --image-id $ami_id --count 1 --instance-type t2.micro
}

function destroy_instance () {
	instance_id=$(aws ec2 describe-instances \
	 --filters "Name=instance-state-name,Values=running" \
	 | jq -r ".Reservations[0] | .Instances[] | .InstanceId")
	aws ec2 terminate-instances --instance-ids $instance_id
}


function check_instances () {
	running_instances=$(aws ec2 describe-instances \
	 --filters "Name=instance-state-name,Values=running" \
	 --query "Reservations[*].Instances[*].InstanceId" --output text | wc -l)
}

main () {
	while [ "$number_messages" != 0 ]
	check_messages
	check_instances
	let threshold="($number_messages + 9) / 10 - $running_instances"
	echo "Workload is $threshold"
	do
		if [ $running_instances -lt 5 ] && [ $threshold -gt 0 ]
		then
			echo 'Launching an instance...'
			launch_instance
		elif [ $running_instances -eq 0 ] && [ $threshold -le 0 ]
		then
			echo 'There are no instances yet or the process has been completed'
		elif [ $running_instances -eq 5 ] && [ $threshold -gt 0 ]
		then
			echo 'Maximum number reached, cannot create any more instances...'
		else
			echo 'Destroying an instance...'
			destroy_instance
		fi
	echo 'Next check in 15s'
	sleep 15
	done
}

main

