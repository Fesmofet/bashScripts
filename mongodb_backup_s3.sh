SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

SYS_USER_NAME="admin1"
S3_SCHEME="s3://"
BUCKET_NAME="waivio-backup"
ENDPOINT="https://nyc3.digitaloceanspaces.com"

BACKUPS_DIR="/home/$SYS_USER_NAME/mongo_backups/"
EXPIRATION_DATE=`date -d"-7 days" +%s`
PATH_TO_FILE=$(find $BACKUPS_DIR -mtime -1 -type f | head -n 1)
FILE_NAME=${PATH_TO_FILE##*/}

echo "performing copying of Mongo production database to aws"

aws s3 cp $PATH_TO_FILE $S3_SCHEME$BUCKET_NAME --endpoint=$ENDPOINT

aws s3 ls $BUCKET_NAME/ --endpoint=$ENDPOINT |while read -r line;
 do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`
    if [ $createDate -lt $EXPIRATION_DATE ]
      then
        fileToDelete=`echo $line|awk {'print $4'}`
        echo $fileToDelete
        if [ $fileToDelete != "" ]
          then
            aws s3 rm $S3_SCHEME$BUCKET_NAME/$fileToDelete --endpoint=$ENDPOINT
        fi
    fi
 done;

echo "Database backup complete!"
