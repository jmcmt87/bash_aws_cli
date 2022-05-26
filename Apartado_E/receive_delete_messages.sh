#! /bin/bash
# Author: Jorge Marcos Martos

queue_url=$(aws sqs list-queues --query QueueUrls[0])
queue_url="${queue_url%\"}"
queue_url="${queue_url#\"}"

while sleep 6
do
	msg=$(aws sqs receive-message --queue-url $queue_url)

	if [ ! -z "$msg" ]
	then
		receipt=$(echo "$msg" | jq -r '.Messages[] | .ReceiptHandle')
		aws sqs delete-message --queue-url $queue_url --receipt-handle $receipt
		echo 'message deleted, waiting 6 seconds to delete the next one'
	fi
done
echo 'All messages have been deleted'
