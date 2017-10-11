#!/usr/bin/bash
dates=$(date +%d%m%Y)
sh /etc/backup_system/new_project_backup/controller_total.sh >> /etc/backup_system/new_project_backup/logs/$dates"_ctotal.log"
