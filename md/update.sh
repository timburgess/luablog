#!/bin/bash

# Loop through each markdown file
for FILE in $(ls *md) ; do
    echo "Processing $FILE"
    # strip file extension
    TITLE="${FILE%%.*}"
    REDIS_KEY="post:$TITLE:log" 
    # get json log output with unix timestamp date
    OUTPUT=$(exec git log --pretty=format:'{"commit": "%H", "author": "%an <%ae>", "timestamp": %at, "message": "%s"},' -- $FILE)
    # Strip last ,
    OUTPUT="${OUTPUT%%,}"
    # Switch linesbreaks to , with goal to eventually make a list
    OUTPUT=$(echo $OUTPUT | tr "\n" ",")
    # Strip last ,
    OUTPUT="${OUTPUT%%,}"
    # Json list
    OUTPUT="[$OUTPUT]"
    #echo $OUTPUT
    # Feed the output into redis
    #echo "SET $REDIS_KEY '$OUTPUT'" | redis-cli > /dev/null
    echo "SET $REDIS_KEY '$OUTPUT'" | redis-cli
    # Find first timestamp of post
    TIMESTAMP=$(exec git log --pretty=format:"%ct" --reverse -- $FILE | head -1)
    # Add the post to the sorted set of posts
    #echo "ZADD posts $TIMESTAMP $TITLE" | redis-cli > /dev/null
    echo "ZADD posts $TIMESTAMP $TITLE" | redis-cli
done


