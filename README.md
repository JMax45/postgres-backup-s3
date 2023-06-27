# postgres-backup-s3

**Backup PostgreSQL databases to S3 Periodically**

`postgres-backup-s3` is a package for **Arch Linux** that facilitates the backup of PostgreSQL databases to Amazon S3. This package allows you to automate the process of creating regular backups of your PostgreSQL databases and storing them in an S3 bucket.

## Installation

To install `postgres-backup-s3`, follow these steps:

1. Clone the `postgres-backup-s3` repository from GitHub:

   ```bash
   git clone https://github.com/JMax45/postgres-backup-s3
   ```

2. Change to the `postgres-backup-s3` directory:

   ```bash
   cd postgres-backup-s3
   ```

3. Build and install the package using `makepkg`:

   ```bash
   makepkg -si
   ```

## Configuration

To set up the configuration for `postgres-backup-s3`, you need to modify the `/etc/postgres-backup-s3.conf` file. The default configuration file looks like this:

```ini
# postgres-backup-s3.conf
# Configuration file for Postgres backup to S3

# Backup 1
[backup1]
postgres_host = localhost
postgres_port = 5432
postgres_user = myuser
postgres_password = mypassword
postgres_database = database
s3_access_key_id = myaccesskey
s3_secret_access_key = mysecretkey
s3_bucket = mybucket
```

You can specify multiple backups by adding additional sections to the configuration file. Each section represents a separate backup, for example:

```ini
# Backup 1
[backup1]
postgres_host = localhost
postgres_port = 5432
postgres_user = myuser
postgres_password = mypassword
postgres_database = database
s3_access_key_id = myaccesskey
s3_secret_access_key = mysecretkey
s3_bucket = mybucket

# Backup 2
[backup2]
postgres_host = localhost
postgres_port = 5432
postgres_user = myuser
postgres_password = mypassword
postgres_database = database
s3_access_key_id = myaccesskey
s3_secret_access_key = mysecretkey
s3_bucket = mybucket
```

To customize the configuration, replace the placeholder values in the configuration file with your own PostgreSQL and S3 credentials. You can provide multiple backup configurations by creating additional sections with unique names (e.g., `[backup2]`, `[backup3]`, etc.) and specifying their respective settings.

## Timer Configuration

The `postgres-backup-s3` package includes a timer that triggers the backup process at regular intervals. By default, the timer is set to create backups every 60 minutes.

To modify the timer interval, use the following command:

```bash
sudo postgres-backup-s3 --update-timer <myval>
```

Replace `<myval>` with the desired time interval. For example, to create backups every 2 hours, you would run:

```bash
sudo postgres-backup-s3 --update-timer 2h
```

For detailed information on the syntax and available options, refer to the [OnUnitActiveSec](https://www.freedesktop.org/software/systemd/man/systemd.timer.html#Options) documentation.

## Starting the Timer

To start the timer and initiate the backup process, execute the following command:

```bash
sudo systemctl start postgres-backup-s3.timer
```

This command will start the timer, and backups will be created based on the configured interval.

## Enabling Timer on System Startup

To ensure that the timer starts automatically when the system boots up, enable it using the following command:

```bash
sudo systemctl enable postgres-backup-s3.timer
```

Enabling the timer will make it persistent across system reboots.