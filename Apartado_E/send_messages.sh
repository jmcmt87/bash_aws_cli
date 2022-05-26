#! /bin/bash
# Author: Jorge Marcos Martos

function queue_availability () {
	queues=$(aws sqs list-queues)

	if [ -z "$queues" ]
	then
        	echo 'No queues available, creating one...'
        	aws sqs create-queue --queue-name MessagesQueue
	else
        	echo 'There is one queue available, using it...'
	fi

	queue_url=$(aws sqs list-queues --query QueueUrls[0])
	queue_url="${queue_url%\"}"
	queue_url="${queue_url#\"}"
}

function messages () {
    number=1
    while [ $number -le 100 ]
    do
            aws sqs send-message --queue-url $queue_url \
             --message-body "This is the message number $number"

            number=$(( number + 1 ))
    done
}

function check_queue () {
	queue_check=$(aws sqs get-queue-attributes --queue-url $queue_url \
	 --attribute-names ApproximateNumberOfMessages)

	number_messages=$(echo $queue_check | jq -r  '.Attributes.ApproximateNumberOfMessages')
}

function purge_send_messages () {
	if [ $number_messages -gt 0 ]
	then
        	echo 'The queue is full, purging it...'
        	aws sqs purge-queue --queue-url $queue_url
        	echo 'The queue has been successfully emptied, sending 100 messages...'
        	messages
	else
        	echo 'The queue is empty, sending 100 messages...'
        	messages
	fi
}

function main () {
	queue_availability
	check_queue
	purge_send_messages
}

main
