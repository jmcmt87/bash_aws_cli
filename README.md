The run.sh script runs the other files, the first will check if there is a SQS queue, it will create it if it doesn't exist yet and it will purge it if it already exists, and then it will send 100 messages. The second process will check how many EC2 instances are currently running every 15 seconds and it will destroy or create EC2 instances depending on how many messages are in the SQS queue, the third process will delete 1 message every 6 seconds.
