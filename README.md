# Database Backup Script (MySQL & PostgreSQL) → S3 via rclone

A production-ready Bash script to automatically back up multiple MySQL and PostgreSQL databases and upload them to any S3-compatible object storage (e.g., Arvan Cloud, AWS S3, MinIO) using rclone.

## Configuration Format
config for `databases.conf`

```conf
# type|database|host|user|password
postgres|sample|127.0.0.1|postgres|postgres                          
postgres|sample|127.0.0.1|postgres|postgres
```

config for .env

```env
S3_REMOTE=arvan # remote name in rclone
S3_BUCKET=bucket-name # name of bucket
```

## Run 

```bash
# add access 
sudo chmod +x run.sh
# run scipt
bash run.sh
```

