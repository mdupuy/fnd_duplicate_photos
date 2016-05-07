#!/bin/bash 
# find all duplicate jpeg files in a imgDirectory
# results are only printed to a file, no modifications of files are done
# if you wish to modify (i.e. move or delete) duplicate files find the comment
# ##DO WHATEVER YOU WISH TO DUPLICATE FILES HERE## inside of this script and 
# uncomment one of my suggested actions or make your own
# This script was written completely offline with only "man bash" for help
# it is probably crap to a veteran bash script writer but it shouldn't do any harm
# feel free to fix, modify, update.
# Thanks!  -- Matthew Du Puy, matt@internetonastick.net

## Feel free to modify any of these default values ##
cmpBytes=4096  #number of bytes to compare in files
outputFile=~/Desktop/dupicate_photos_list.txt #print results to this file
imgDirectory=~/Pictures/Photos\ Library.photoslibrary/Masters #look in this directory
fileTypes="jp*g mp*g avi mp4 mov txt"


#function innerForFileLoop {
#
#}

echo
#echo $BASH_ARGC ${BASH_ARGV[0]} ${BASH_ARGV[1]} ${BASH_ARGV[2]} ${BASH_ARGV[3]} ${BASH_ARGV[4]} 

#decode command line input override of defaults
if [ $BASH_ARGC ]; then 
	#echo $[$BASH_ARGC]
	for (( flag=$[$BASH_ARGC-1] ; $[$flag+1] ; flag-=1 )); do
		#echo ${BASH_ARGV[flag]}
		# What directory should we search?
		if [ "${BASH_ARGV[flag]}" == "-d" ]; then 
			#echo directory ${BASH_ARGV[flag-1]}
			if [ "${BASH_ARGV[flag-1]}" ]; then
				flag=$flag-1
				echo directory "${BASH_ARGV[flag]}"
				imgDirectory="${BASH_ARGV[flag]}"
				exists=$(ls "$imgDirectory")
				if ! [[ "$exists" ]]; then 
					echo "$imgDirectory" does not exist
					exit 1
				fi
				continue
			else
				echo Error, no directory following "${BASH_ARGV[flag]}" flag
				exit 2
			fi
		fi
		
		# Where should we put the output list of duplicate files?
		if [ "${BASH_ARGV[flag]}" == "-o" ]; then 
			#echo output file ${BASH_ARGV[flag-1]}
			if [ "${BASH_ARGV[flag-1]}" ]; then
				flag=$flag-1
				echo output file "${BASH_ARGV[flag]}"
				outputFile="${BASH_ARGV[flag]}"
#				permitted="$(touch "$outputFile")"
#				echo $permitted
#				if [ "$permitted" > 0]; then 
#					echo Can't write to"$outputFile"
#					exit 1
#				fi
				continue
			else
				echo Error, no file name following "${BASH_ARGV[flag]}" flag
				exit 2
			fi
		fi

		#How big of a "cmp" comparison should we do in bytes? i.e. not the WHOLE file
		if [ "${BASH_ARGV[flag]}" == "-s" ]; then 
			#echo bytes to compare ${BASH_ARGV[flag-1]}
			if [ "${BASH_ARGV[flag-1]}" ]; then
				flag=$flag-1
				echo bytes to compare ${BASH_ARGV[flag]} !! caution, too low a number will cause false positives
				cmpBytes="${BASH_ARGV[flag]}"
#				valid=$(cmp -n $cmpBytes /dev/random /dev/random)
#				echo $valid
#				exit
				continue
			else
				echo Error, no number of bytes following "${BASH_ARGV[flag]}" flag
				exit 2
			fi
		fi		
		
		#What file types should we look for?
		if [ "${BASH_ARGV[flag]}" == "-t" ]; then 
			#echo file extension/type ${BASH_ARGV[flag-1]} 
			if [ "${BASH_ARGV[flag-1]}" ]; then
				flag=$flag-1
				echo file extension/type "${BASH_ARGV[flag]}"
				fileTypes="${BASH_ARGV[flag]}"
				continue
			else
				echo Error, no file extension types following "${BASH_ARGV[flag]}" flag
				exit 2
			fi
		fi			
		
		#Help!!!!
		if [ "${BASH_ARGV[flag]}" == "-h" ] || [ "${BASH_ARGV[flag]}" == "-?" ] || [ "${BASH_ARGV[flag]}" == "--help" ]; then 
			echo
			echo "Options:"
			echo "-d <search_directory> -- path of directory to search for duplicate files"
			echo "-o <output_file> -- path to output duplicate file list generated by this script"
			echo "-s <number> -- number of bytes to compare in each file !! too low a number will generate" 
			echo "               false positives"
			echo "-t <\"file_ext\"> -- Default file extensions are \"jp*g mp*g avi mp4 mov\" this is case"
			echo "                 insensitive. Use -t to override defaults. Use spaces to separate"
			echo "                 extensions and quote multiple exts. *'s are allowed (see defaults)."
			echo "-h, -?, --help -- I'm not going to dignify this"
			echo
			echo "Example: fnd_duplicate_photos.command -d ~/Desktop/camera -t \"jp*g png\" -o /tmp/diff.txt -s 4096"
			echo "will search ~/Desktop/camera for jpeg, jpg and png files. It will compare the first 4k bytes"
			echo "of every file and a list of identical files will be output to /tmp/diff.txt"
			echo
			echo "Apple Photos removed the ability to search its Master photo library for duplicate photos."
			echo "This script will search any directory you choose but defaults to the Photos Library Master"
			echo "photo directory and searches for jpep, mp4, mov, mpeg and avi files that are duplicated"
			echo "and outputs the list to a file of your choosing (Default, ~/Desktop/dupicate_photos_list.txt)"
			echo
			echo "This script will not move or modify any files, it just gives you a list of duplicates"
			echo "If you want to do anything to the duplicate file, see the commented out line in the script:"
			echo "##DO WHATEVER YOU WISH TO DUPLICATE FILES HERE##"
			echo "I've made a few suggestions you can uncomment."
			echo
			echo "I wrote this with only 'man bash', no online reference material. I'm sure it is garbage to"
			echo "any veteran scripter. I make no guarantees to reliability or safety but it is safe."
			echo
			exit 0
		fi			
		
	done
fi

echo "These files with extension(s): $fileTypes, in:" > "$outputFile"
echo "$imgDirectory"  >> "$outputFile"
echo "were found to be identical:" >> "$outputFile"
echo "" >> "$outputFile"

cd "$imgDirectory"
echo Getting file list.
#find all jpeg and movie files and put them in a space separated list
#echo "$fileTypes"
#replace spaces with "SPaCe" for bash for loop to parse lists correctly
for fileExt in $fileTypes; do
	echo "*.$fileExt"
	list+="$(find . -type f -iname "*.$fileExt" |sed -e s/[[:space:]]/SPaCe/g) "
	#list+="$(find . -type f -iname "*" |sed -e s/[[:space:]]/SPaCe/g) "
done

#echo o"$list"o
if [ "$list" == "     " ]; then
	#echo $list
	echo No expected media files found in \""$imgDirectory"\"
	echo "No expected media files found in:" > "$outputFile"
	echo "\""$imgDirectory"\"" >> "$outputFile"
	echo "Expected: $fileTypes" >> "$outputFile"
	open "$outputFile"
	exit 0
fi

#echo Getting file count.
declare -i fileCount=0
#time for file in $list; do
for file in $list; do
	#echo $fileCount echo $file
	fileCount=$[$fileCount + 1]
	#fileCount++;
done
fileCount=$[$fileCount + 1]
echo Found $fileCount files. Searching for duplicates. `date`


dayTime=`date | awk '{print $4}'`
declare -i hours=`echo $dayTime | sed -e 's/:[0-9][0-9]:[0-9][0-9]//'| sed 's/^0*//'`
hours=$[$hours*60*60]
declare -i minutes=`echo $dayTime |sed 's/[0-9][0-9]:*//'| sed 's/:[0-9][0-9]//'| sed 's/^0*//'`
minutes=$[$minutes*60]
declare -i seconds=`echo $dayTime |sed 's/[0-9][0-9]:[0-9][0-9]://' | sed 's/^0*//'`   #strip leading zeros

startSeconds=$[$minutes + $hours + $seconds]
echo $startSeconds

declare -i progressCount=0
for file in $list; do 
   #echo $file
   ## to compare the 1st $cmpBytes bytes of ALL files. This takes a while.
   #if [ "${BASH_ARGV[0]}" == "full" ] || [ "${BASH_ARGV[1]}" == "full" ]; then
#   if [ 1 ]; then
       #echo Doing a comparision of all files, not just file names. This could take a while.
    declare -i internalLoopProgCnt=0
	for allfiles in $list; do
		fileName=$(echo $file |sed -e s/SPaCe/\ /g)
		all=$(echo $allfiles |sed -e s/SPaCe/\ /g)
		#echo fileName $fileName all $all
			if [ "$fileName" !=  "$all" ]; then
		   #echo fileName $fileName all $all
		   same=$(cmp -n $cmpBytes "$fileName" "$all")  # same is zero if the files are identical
		   if ! [[ "$same" ]]; then 
			  echo $fileName \& $all are identical
			  ## now see if we already found this match in reverse order
			  matchList+="$allfiles$file "
			  uniqueMatch=1
			  for mirrorMatches in $matchList; do
				pair="$file$allfiles"
				if [ $pair == $mirrorMatches ]; then
					echo "  match already found"
					uniqueMatch=0
					break 1
				fi
			  done
			  if [ $uniqueMatch == 1 ]; then
				#echo adding to file
				echo $fileName \& $all are identical  >> "$outputFile"
				##DO WHATEVER YOU WISH TO DUPLICATE FILES HERE##
				## i.e. move one of the duplicate files to the Trash or a folder on your desktop
				#mv "$fileName" ~/.Trash/
				##or##
				#mv "$fileName" ~/Desktop/duplicate_files/
			  fi
		   fi
		fi
		internalLoopProgCnt=$[$internalLoopProgCnt + 1]
		if [ "$intProgress" != "$[($internalLoopProgCnt * 100) / $fileCount]" ]; then
			intProgress=$[($internalLoopProgCnt * 100) / $fileCount]
			#echo -n "$intProgress% "
			echo -n .
		fi
		
		#echo $internalLoopProgCnt $fileCount
		if [ "$[$internalLoopProgCnt + 1]" == "$fileCount" ]; then
			echo !
		fi
	done
	
	progressCount=$[$progressCount + 1]
	if [ "$progress" != "$[($progressCount * 100) / $fileCount]" ]; then
		progress=$[($progressCount * 100) / $fileCount]
		#echo $[$progressCount] of $[$fileCount] done.
		echo
		echo -n "$progress% done. -- " 
		#echo -n `date`" -- "
		
		dayTime=`date | awk '{print $4}'`
		hours=`echo $dayTime | sed -e 's/:[0-9][0-9]:[0-9][0-9]//'| sed 's/^0*//'`
		hours=$[$hours*60*60]
		minutes=`echo $dayTime |sed 's/[0-9][0-9]:*//'| sed 's/:[0-9][0-9]//'| sed 's/^0*//'`
		minutes=$[$minutes*60]
		seconds=`echo $dayTime |sed 's/[0-9][0-9]:[0-9][0-9]://' | sed 's/^0*//'`   #strip leading zeros
		
		timeInSec=$[$hours + $minutes + $seconds]
		elapsed=$[$timeInSec - $startSeconds]
		echo -n $elapsed sec elapsed" -- "
		
		#avgSec=$[$elapsed / $progress]
		avgSec=$(bc -l <<< "$elapsed/$progress")
		#echo -n " ••$avgSec average seconds•• "
		
		#timeEstimate=$[$[101 - $progress] * $avgSec]
		#timeEstimate=$(bc -l <<< "(101-$progress)*$avgSec")
		timeEstimate=$(bc -l <<< "(100*$avgSec)")
		#echo -n " ••approx $timeEstimate seconds for total job•• "
		
		#remainingSec=$[$timeEstimate - $elapsed]
		remainingSec=$(bc -l <<< "$timeEstimate-$elapsed"| sed 's/\.[0-9]*//')
		#echo remainingSec $remainingSec
		
		hours=$[$remainingSec/60/60]
		remainingSec=$[$remainingSec - $[$hours*60*60]]
		if [[ $hours > 0 ]] ; then
			echo -n $hours "hours "
		fi
		
		minutes=$[$remainingSec/60]
		remainingSec=$[$remainingSec - $[$minutes*60]]
		if [[ $minutes > 0 ]] ; then
			echo -n $minutes "minutes "
		fi

		echo $remainingSec seconds remaining.
		
		#echo -n $[$remainingSec/60] minutes 
		#$[$remainingSec%60] sec remaining.
	fi

#   elif [ 0 ]; then   # compare file names and diff
#
#	## this just checks for identical file names and only diffs files with the same name.
#	## It is much faster but less accurate. If a same image has different names, diff -r won't detect it
#	   fileName=$(echo $file |sed -e s/SPaCe/\ /g)
#	   #echo "$fileName"
#	   #diff -rs "$fileName" .
#	   #diff -rs "$fileName" .|sed 's/Files //'|sed 's/ are identical//'|sed -e s/[[:space:]]/SPaCe/g|sed -e s/SPandSP/\ /
#
#	   identical=$(diff -rs "$fileName" .|sed 's/Files //'|sed 's/ are identical//'|sed -e s/[[:space:]]/SPaCe/g|sed -e s/SPandSP/\ /)
#	   #echo $identical
#	   file1=0
#	   file2=0
#	   for file in $identical
#	   do
#		if [ "$file1" == 0 ]; then
#		   file1=$file
#		   #echo 1 file1 $file1
#			elif [ "$file1" != 0 ]; then
#			   file2=$file
#		   #echo 2 file1 $file1 file2 $file2
#		   if [ "$file1" != "$file2" ]; then
#			  echo $file1 and $file2 are identical >> "$outputFile"
#			  #do something about it...
#			  #mv "$file2" ~/.Trash/
#		   fi
#		   file1=0
#			fi
#	   done
#	   
#	elif [ 1 ]; then   
#	   for allfiles in $list
#	   do
#		fileName=$(echo $file |sed -e s/SPaCe/\ /g)
#		all=$(echo $allfiles |sed -e s/SPaCe/\ /g)
#		#echo fileName $fileName all $all
#		if [ "$fileName" !=  "$all" ]; then
#			file1=$(echo "$fileName" | sed 's/.*\///')
#			file2=$(echo "$all" | sed 's/.*\///')
#			#echo $fileName is $file1 -- $all is $file2
#			if [ "$file1" ==  "$file2" ]; then
#				echo compare $fileName $all
#				#diff -s "$fileName" "$all"
#			fi
#		fi
#	   done  
#	   
#	fi #if [ ${BASH_ARGV[0]} == "full" ]; then
done

matchNum=$(wc -l "$outputFile" | sed 's/\/.*//')
matchNum=$(($matchNum - 4)) #subtract first line
echo Found $matchNum unique matches in "$imgDirectory".
echo Matches listed in "$outputFile". 
open "$outputFile"
