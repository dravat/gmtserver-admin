#!/bin/bash
# srv_git_update.sh
#
# Run git pull on gmtserver and determine if any file was updated.
# If so, run the update_file_hash.sh script as well
# P. Wessel, Oct. 3, 2019

# 1. Change directory to top dir of working directory
cd /export/gmtserver/gmt/gmtserver-admin
# Check changes and update file hash
# 2. Make sure we are on the master branch
git checkout master
# 3. Fetch from the remote repository
git fetch origin master
# 4. Check if the local master branch is behind the remote one
count=`git rev-list master ^origin/master --count`
if [ "$count" -ne "0" ]; then	# 5. There will be updates
	# 5a Update the local repo
	git pull origin master
	# 5b Update the SHA256 hash table
	bash scripts/srv_update_sha256.sh
fi
