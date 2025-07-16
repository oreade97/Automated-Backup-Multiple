# Multi-Volume NetApp Scheduled Backups with Google Cloud Functions

This repository contains a **Google Cloud Function** that automates the creation and management of **NetApp volume backups** for multiple volumes using a CSV file. The function reads a CSV file that lists volumes and their corresponding backup vaults to schedule backups on a preconfigured routine. Each backup is labeled for easy identification, and if the number of backups for any volume exceeds the configured limit (default is **24**), the oldest backup is deleted before creating a new one.

## How It Works

1. **Terraform Deployment**:  
   All required resources are deployed via Terraform. This includes storage pools, volumes, backup vaults, API configurations, and the necessary permissions.

2. **Scheduled Trigger**:  
   **Cloud Scheduler** triggers the Cloud Function via a **Pub/Sub** topic based on a cron schedule.

3. **CSV-Driven Backup Process**:  
   - The Cloud Function reads a CSV file (packaged with the function) that lists the volumes and their corresponding backup vaults.
   - For each row in the CSV, the function triggers the NetApp API to create a backup.
   - Backups are assigned a specific label.
   - If more than the configured maximum number (default 24) of backups exists for a volume, the oldest one is automatically deleted before a new backup is created.

## Prerequisites

### APIs

Ensure that the following APIs are enabled in your Google Cloud project:

- **Cloud Functions API**
- **Cloud Build API**
- **Pub/Sub API**
- **NetApp API**
- **Cloud Scheduler API**

*Note*: The `apis.tf` Terraform configuration file is set up to enable these APIs automatically.

### Permissions

- The service account or user deploying this function must have the **Google Cloud NetApp Volumes "NetApp Admin" role**.
- When deploying via Terraform, the Terraform service account is automatically granted the necessary roles via the `iam.tf` file.

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/oreade97/Netapp-Scheduled-Backups.git


