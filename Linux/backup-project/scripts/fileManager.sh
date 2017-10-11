#!/usr/bin/bash
#
# Creado 21/08/2017 cvelasquez
# Encargado de controlar el exceso de archivos
# en el directorio de respaldo que pueda generar
# sobreutilizacion y saturación de disco.
# 

source /etc/backup_system/new_project_backup/sys_options.conf
find $btDirectoryFinalStorageCompress*.gz -mtime +5 -type f -delete
