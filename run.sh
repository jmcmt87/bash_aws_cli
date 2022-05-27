#!/bin/bash

echo "Initializing program..."
sh ./send_messages.sh
sleep 15
sh ./check_create_instances.sh
sleep 5
sh ./receive_delete_messages.sh
