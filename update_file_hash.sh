#!/bin/bash -e
# Find all files on gmtserver and update the hash table in the event files are
# younger than the hash table itself. Files deleted are thus removed from the hash table.
# We only consider the earth_relief_xxy.grd files and the cache dir. SRTM tiles not included
# For now we also skip the BLueMarble_*.tif files so they don't get downloaded by accident.
# If an error is detected we quit.

# 0. Directory with GMT remote data files
DATA=/export/gmtserver/gmt/data

# 1. Make a list of all the earth relief first and then cache files (skip BlueMarble files for now)
ls $DATA/earth_relief_???.grd > /tmp/$$.lis
ls $DATA/cache/* | grep -v BlueMarble_ >> /tmp/$$.lis

# 2. Write number of files found to the new hash table header
wc -l < /tmp/$$.lis | awk '{printf "%d\n", $1}' > new_gmt_hash_server.txt

# 2. Loop over the files we found and update hash table if needed
while read path; do
	file=`basename $path`
	if [ $path -nt $DATA/gmt_hash_server.txt ]; then	# File was updated after current hash table was made, redo hash
		hash=`sha256sum $path | awk '{print $1}'`
		size=`ls -l $path | awk '{print $5}'`
		printf "%s\t%s\t%s\n" $file $hash $size >> new_gmt_hash_server.txt
	else	# Can use the previous hash record
		grep -w $file $DATA/gmt_hash_server.txt >> new_gmt_hash_server.txt
	fi
done < /tmp/$$.lis
rm -f /tmp/$$.lis

# 3. Overwrite old file with new hash table

#cp -f new_gmt_hash_server.txt $DATA/gmt_hash_server.txt
