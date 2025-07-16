import base64
import csv
import json
import datetime
import os
import time
from google.cloud import netapp_v1

# Constants for backup management
BACKUP_LABEL_KEY = "createdby"
BACKUP_LABEL_VALUE = "hourly_backup_function"
NAME_PREFIX = "backup-"
MAX_BACKUPS = 24  # Number of backups to retain
DELAY_BETWEEN_BACKUPS = 5  # Delay in seconds

def create_volume_backup(event, context):
    print("Received Pub/Sub trigger for NetApp Volume Backup creation.")
    
    # Retrieve the CSV path from environment variables
    csv_path = os.environ.get("VOLUME_CSV_PATH")  # Ensure this path is correctly set in Cloud Function env vars
    
    # Create a client
    client = netapp_v1.NetAppClient()

    try:
        # Read the CSV file
        with open(csv_path, mode='r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                volume_name = row.get('volume_name')
                region = row.get('region')
                backup_vault = row.get('backup_vault')
                
                if not volume_name or not region or not backup_vault:
                    print(f"Skipping row due to missing required fields: {row}")
                    continue
                
                # Generate a timestamped backup name
                timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
                backup_name = f"{NAME_PREFIX}{volume_name}-{timestamp}"
                
                # Define the backup vault resource name and volume name
                backup_vault_name = f"projects/{os.environ.get('PROJECT_ID')}/locations/{region}/backupVaults/{backup_vault}"
                volume_resource_name = f"projects/{os.environ.get('PROJECT_ID')}/locations/{region}/volumes/{volume_name}"
                
                try:
                    # List existing backups with the specific label
                    backups = client.list_backups(parent=backup_vault_name)
                    
                    # Filter backups with the specific label and sort by creation time
                    labeled_backups = sorted(
                        [backup for backup in backups if backup.labels.get(BACKUP_LABEL_KEY) == BACKUP_LABEL_VALUE],
                        key=lambda b: b.create_time
                    )
                    
                    # Check if there are already MAX_BACKUPS or more
                    if len(labeled_backups) >= MAX_BACKUPS:
                        # Delete the oldest backup first
                        oldest_backup = labeled_backups[0]
                        print(f"Deleting oldest backup: {oldest_backup.name}")
                        delete_operation = client.delete_backup(name=oldest_backup.name)
                        delete_operation.result()  # Wait for the delete operation to complete
                        print(f"Oldest backup deleted: {oldest_backup.name}")
                    
                    # After deletion (if necessary), proceed to create the new backup
                    print(f"Initiating new backup for volume {volume_resource_name} in backup vault: {backup_vault_name}")
                    
                    # Define the backup creation request
                    backup_request = netapp_v1.CreateBackupRequest(
                        parent=backup_vault_name,
                        backup_id=backup_name,
                        backup=netapp_v1.Backup(
                            source_volume=volume_resource_name,
                            labels={BACKUP_LABEL_KEY: BACKUP_LABEL_VALUE}
                        )
                    )
                    
                    # Start the backup operation (non-blocking)
                    client.create_backup(request=backup_request)
                    print(f"Backup creation started for {volume_name}")

                except Exception as e:
                    print(f"Error managing backup for volume {volume_name}: {e}")
                
                # Introduce a delay before processing the next volume
                time.sleep(DELAY_BETWEEN_BACKUPS)

    except Exception as e:
        print(f"Error reading CSV file: {e}")
