#!/bin/bash

# Step 1: Bring up the network
minifab netup -s couchdb -e true -i 2.4.8 -o policedepartment.claim.com

# Step 2: Create a channel
minifab create -c autochannel

# Step 3: Join peers to the channel
minifab join -c autochannel

# Step 4: Update anchor peers
minifab anchorupdate

# Step 5: Generate the profile
minifab profilegen

# Step 6: Deploy the chaincode
minifab ccup -n Assignment3 -l go -v 1.0 -d false -r true
