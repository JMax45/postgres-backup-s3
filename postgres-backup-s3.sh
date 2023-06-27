#!/bin/bash

update_timer() {
    REPLACEMENT_VALUE="$1"
    TARGET_KEY="OnUnitActiveSec"
    CONFIG_FILE="/usr/lib/systemd/system/postgres-backup-s3.timer"
    sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE
}

# Check if the "--update-timer" option is provided
if [[ $1 == "--update-timer" ]]; then
    # Check if a new interval is provided
    if [[ -n $2 ]]; then
	echo "Updated postgres-backup-s3.timer with value $2"
	echo "Remember to restart with sudo systemctl daemon-reload && sudo systemctl restart postgres-backup-s3.timer"
        update_timer "$2"
	exit 0
    else
        echo "Please provide a new interval value with the --update-timer option."
        exit 1
    fi
fi

process_backup_section() {
    # Variables to store backup configuration
    local postgres_host
    local postgres_port
    local postgres_user
    local postgres_password
    local postgres_database
    local s3_access_key_id
    local s3_secret_access_key
    local s3_bucket

    # Read the backup section
    while IFS='=' read -r key value; do
        # Remove leading/trailing whitespace from key and value
        key="${key// /}"
        value="${value// /}"

        # Assign values to variables based on the key
        case "$key" in
        postgres_host)
            postgres_host="$value"
            ;;
        postgres_port)
            postgres_port="$value"
            ;;
        postgres_user)
            postgres_user="$value"
            ;;
        postgres_password)
            postgres_password="$value"
            ;;
        postgres_database)
            postgres_database="$value"
            ;;
        s3_access_key_id)
            s3_access_key_id="$value"
            ;;
        s3_secret_access_key)
            s3_secret_access_key="$value"
            ;;
        s3_bucket)
            s3_bucket="$value"
            ;;
        esac
    done <<< "$(sed -n "/^\[$1\]/,/^$/p" "$filename")"

    # Process the backup configuration
    echo "Processing backup: $1"
    echo "Postgres Host: $postgres_host"
    echo "Postgres Port: $postgres_port"
    echo "S3 Bucket: $s3_bucket"
    echo

    AWS_ACCESS_KEY_ID="$s3_access_key_id"
    AWS_SECRET_ACCESS_KEY="$s3_secret_access_key"
    
    local DATE_TIME=$(date +%Y%m%d_%H%M%S)
    local FILENAME="${DATE_TIME}.sql"
    # Perform the database dump
    export PGPASSWORD="$postgres_password"
    pg_dump -h "$postgres_host" -U "$postgres_user" -d "$postgres_database" -p "$postgres_port" -f "/tmp/$FILENAME"
    unset PGPASSWORD

    # Copy the SQL file to S3
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    aws s3 cp "/tmp/$FILENAME" "s3://$s3_bucket/"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY

    # Cleanup the temporary SQL file
    rm "/tmp/$FILENAME"
}

# Filename of the configuration file
filename="/etc/postgres-backup-s3.conf"

# Read the file line by line
while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    # Check if the line starts a new backup section
    if [[ "$line" =~ ^\[[[:alnum:]_]+\]$ ]]; then
        # Extract the backup section name
        backup_name="${line//[}"
        backup_name="${backup_name//]}"

        # Process the backup section
        process_backup_section "$backup_name"
    fi
done < "$filename"

exit 0
