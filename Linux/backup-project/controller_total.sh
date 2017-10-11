#!/bin/bash
#error 0 y success 1
source /etc/backup_system/new_project_backup/sys_function.conf
source /etc/backup_system/new_project_backup/sys_options.conf
#source diff_function.conf
source /etc/backup_system/new_project_backup/dir_forbackup.conf
declare -a directory_array
exclude_upload=""
IFS=""
#function_validate_system $install

mkdir -p $btDirectoryTempUpload
mkdir -p $btDirectoryTempCompress

function_validate_system $install

if [ $? -ne 1 ];then
	echo error1
	# log->error con validacion de sistema
	exit -1
fi
	# log->validacion de archivos de sistema ok
if [ "$btDirectorySaveBackup" == "" ] || [ "$btDirectoryFinalStorageCompress" == "" ] || [ "$btDirectoryTempUpload" == "" ] || [ "$btDirectoryTempCompress" == "" ]; then
	#log->error variables null
	echo error2
	exit -1
fi

function_validate_dir $btDirectorySaveBackup
if [ $? -ne 1 ];then
	echo error3
	# log->error con validacion de directorio guardar total
	exit -1
fi
function_validate_dir $btDirectoryFinalStorageCompress
if [ $? -ne 1 ];then
	echo error4
	# log->error con validacion de directorio guardar total comprimido
	exit -1
fi

function_validate_dir $btDirectoryTempUpload
if [ $? -ne 1 ];then
	echo error10
	# log->error con validacion de directorio guardar total comprimido
	exit -1
fi

function_validate_dir $btDirectoryTempCompress
if [ $? -ne 1 ];then
	echo error10
	# log->error con validacion de directorio guardar total comprimido
	exit -1
fi

function_search_element_in_array ${btDayForBackup[@]} $dayNow
if [ $? -ne 1 ];then
	echo error5
# 	log->event no corresponde hacer respaldo total
#	exit -1
fi

#mkdir -p $btDirectoryTempUpload
#mkdir -p $btDirectoryTempCompress


for registers in ${dirsToBackup[*]}; do
	name=$(echo $registers | awk -F"," '{print $1}' )
	directory=$(echo $registers | awk -F"," '{print $2}' )
	script=$(echo $registers | awk -F"," '{print $3}' )
	maxSizeFiles=$(echo $registers | awk -F"," '{print $4}' )
 	excludeBackup=$(echo $registers | awk -F"," '{print $5}' )
 	upload=$(echo $registers | awk -F"," '{print $6}' )

	if [ "$excludeBackup" != "" ]; then
		excludeBackup="--exclude-from="$excludeBackup
    fi

	if [ "$maxSizeFiles" != "" ]; then
		maxSizeFiles="--max-size="$maxSizeFiles
	fi
	
    directorySegmented=$btDirectorySaveBackup$year"/"$nameMonthNow
    directoryFull=$directorySegmented$directory
    
    # if [ "$upload" == "0" ]; then
    # 	path_folders_compress_exclude=$(echo $path_folders_backup | sed 's/\/$//')
    # 	exclude_upload=$exclude_upload"--exclude="$path_folders_compress_exclude" "
    # fi
    # 
    echo $directory
    echo $directorySegmented
    echo $directoryFull

    function_validate_dir $directoryFull
	if [ $? -ne 1 ];then
		#echo error create
		mkdir -p $directoryFull
	fi
	function_validate_dir $directoryFull
	if [ $? -ne 1 ];then
		#log->error no se puede crear directorio
		echo error6
	else
		#dir backup total debe validar si existe.
		#directorio es backup total + año + nombre mes + el path de la carpeta a respaldar
		
			#existe script antes de realizar backup diferencial ?
			if [ "$script" != "" ]; then
			#echo script ...
			echo "| "execute script $script" |"
			start=$(date +'%s')
			exec_script_before_backup $script
			time_elapsed=$(($(date +'%s') - $start))
			echo "| "$time_elapsed "second |"
			fi
			#echo run rsync total ....
			echo "| sync folder "$directoryFull" |"
			start=$(date +'%s')
			run=$(rsync -av --delete-before --force $maxSizeFiles $directory $directoryFull $excludeBackup)
			time_elapsed=$(($(date +'%s') - $start))
			echo "| "$time_elapsed "second |"
			echo "| compress folder "$directoryFull" |"
			start=$(date +'%s')
				tar -zcvf $btDirectoryTempCompress$name".tar.gz" $directoryFull > /dev/null 2>&1
			time_elapsed=$(($(date +'%s') - $start))
			echo "| "$time_elapsed "second |"
			echo "| validate files compress integrity |"
			start=$(date +'%s')
			if ! tar -tf $btDirectoryTempCompress$name".tar.gz" > /dev/null 2>&1; then
				echo error8
	            #log->error file compress malformed
	        else
		        time_elapsed=$(($(date +'%s') - $start))
				echo "| "$time_elapsed "second |"
				if [ "$upload" == "1" ]; then
					echo "| move file compress to upload |"
					cp $btDirectoryTempCompress$name".tar.gz" $btDirectoryTempUpload
				fi
			fi
	fi

done

#compress all other files with extension tar.gz Compress
echo "| compress all files tar.gz generates compress directory |"
echo $btDirectoryFinalStorageCompress$year$nameMonthNow$now".tar.gz"
echo $btDirectoryTempCompress

start=$(date +'%s')
tar --remove-files -zcvf $btDirectoryFinalStorageCompress$year$nameMonthNow$now".tar.gz" $btDirectoryTempCompress > /dev/null 2>&1
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"
echo "| validate files compress integrity |"

start=$(date +'%s')
if ! tar -tf $btDirectoryFinalStorageCompress$year$nameMonthNow$now".tar.gz" > /dev/null 2>&1; then
	echo error storage compress
    #log->error file compress malformed
fi

#compress all other files with extension tar.gz Upload
echo "| compress all files tar.gz generates upload directory |"
start=$(date +'%s')
tar --remove-files -zcvf $btDirectorySaveBackup$year$nameMonthNow".tar.gz" $btDirectoryTempUpload > /dev/null 2>&1
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"

echo "| validate files compress integrity |"
start=$(date +'%s')
if ! tar -tf $btDirectorySaveBackup$year$nameMonthNow".tar.gz" > /dev/null 2>&1; then
	echo error
    #log->error file compress malformed
else
	time_elapsed=$(($(date +'%s') - $start))
	echo "| "$time_elapsed "second |"
	#upload the last compressed to S3
	echo "| upload the last compressed to S3 upload |"
	start=$(date +'%s')
	s3cmd put $btDirectorySaveBackup$year$nameMonthNow".tar.gz" s3://antilhue-backup/backup/backups_totales/ > /dev/null 2>&1
	time_elapsed=$(($(date +'%s') - $start))
	echo "| "$time_elapsed "second |"
fi
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"

echo "| delete files and directory compress $btDirectoryTempUpload|"
start=$(date +'%s')
rm -rf $btDirectoryTempUpload"*"
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"

echo "| delete files and directory compress $btDirectoryTempCompress|"
start=$(date +'%s')
rm -rf $btDirectoryTempCompress"*"
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"

echo "| delete files and directory compress $btDirectorySaveBackup$year$nameMonthNow.tar.gz |"
start=$(date +'%s')
rm -rf $btDirectorySaveBackup$year$nameMonthNow".tar.gz"
time_elapsed=$(($(date +'%s') - $start))
echo "| "$time_elapsed "second |"

#echo $run
echo success end....

$install""scripts/./fileManager.sh
