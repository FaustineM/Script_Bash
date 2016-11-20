!/bin/bash

# Use of Apple's built-in command line application 'say'
# 2 directory (for each language) : FR and EN.
# From text files in the respective directories /txt, generate audio files in the respective /audio diretories.
# Chose the voice (and accent) according to the language of the text file.

BASE_FOLDER=$(dirname "${BASH_SOURCE[0]}")            # Name of the base folder (EN or FR) and its path
TXT_FOLDER="$BASE_FOLDER/txt"                         # Path to the /txt folder
AUDIO_FOLDER="$BASE_FOLDER/audio"                     # Path to the /audio folder

while read txtpath
do
   if [ $(echo "$txtpath" | grep '/FR/' | wc -l | bc) -eq 1 ]
   # Define the language (FR or EN)
   then
        locale='FR'
        voice='Audrey'                                # Voice with a french accent 
   elif [ $(echo "$txtpath" | grep '/EN/' | wc -l | bc) -eq 1 ]
   then
        locale='EN'
        voice='Agnes'                                 # Voice with an english accent 
   else
        # exit 1                                      # error management
        continue                                      # next iteration
   fi                                                                                                                                    

   audiopath=$(echo "${txtpath%*.txt}.mp4" | sed 's@/txt/@/audio/@g')
   # Replace extension ".txt" by ".mp4"
   # AMend the path : replace "/txt/" by "/audio/"

   audiofolder=$(dirname "$audiopath")                # absolute path to the audio folder
   if [ ! -d "$audiofolder" ]                         # Check if the folder already exist, if not create it
   then
        mkdir -p "$audiofolder"
   fi
        echo "-- Converting \"$txtpath\" to \"$audiopath\" with \"$locale\" locale ($voice)"   # Test 
        say -f "$txtpath" -v "$voice" -o "$audiopath" # Converting the text file (say -f) into an audio file (say -o)

done < <(find "$TXT_FOLDER" -type f -name "*.txt")    # Loop condition : while finding a file with a .txt extension

exit 0      