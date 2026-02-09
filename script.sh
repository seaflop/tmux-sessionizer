#! /usr/bin/bash

# The environment variable for the session's directory name.
dir_env_var="DIRECTORY"

# Create new tmux session with the name of the full directory.
# If the session already exists, attach to it instead.

directory=$(find ~/ -type d | fzf)

# Gracefully exit if we didn't choose a directory
if [ -z "$directory" ]
then
    exit
fi

cd "$directory"

# Tokenize the directory at every instance of a '/'.
IFS='/' read -a dirs_list <<< "$directory"
# Gotta ignore the first directory as it will be blank due to the nature of
# directory structures. We start ndexing from 1.
num_dirs=${#dirs_list[@]}
(( num_dirs-- ))

name=${dirs_list[$num_dirs]}
(( num_dirs-- ))

sessions_to_be_renamed=()

dir_depth=0

while true
do

    tmux_sessions=$(tmux list-sessions -F "#{session_name}")
    found_matched_session=0
    found_duplicate=0

    for session in $tmux_sessions
    do
        env=$(tmux show-environment -t "$session" "$dir_env_var")
        # Check to see if the directory of the session in the loop matches
        # the directory we want to create the session for. If it does
        # match, then just attach to the already existing session and exit
        # the script.
        session_dir="${env#*"$dir_env_var="}"
        if [ "$session_dir" = "$directory" ]
        then
            tmux a -t "$session"
            exit
            # If the session directory is not an exact match, we need to 
            # search to see if the name variable matches the end of the 
            # session name.
            # If we had found a match for the name variable to the end of the 
            # session name, then we want to rename the existing directory by 
            # adding its parent directory to the name. Then we want to break 
            # out of the loop to restart going through all the session names.
        else
            if [[ "$session" == *"$name" ]]
            then
                found_matched_session=1
                # Mark this session as having to be renamed. We add the session
                # name to a list and then after breaking out of the loop rename
                # whatever sessions are in the list with the necessary amount
                # of parent directories.
                for i in "${sessions_to_be_renamed[@]}"
                do
                    if [ "$i" == "$session" ]
                    then
                        found_duplicate=1
                        break
                    fi
                done
                if [ $found_duplicate -eq 0 ]
                then
                    sessions_to_be_renamed+=("$session")
                fi
            else
                continue
            fi
        fi
    done

    # If we ran through the entire loop and found no matches for existing
    # sessions, then we can just break out of the while loop and create a new
    # session with name name. Otherwise, rename our new session by adding 
    if [ $found_matched_session -eq 0 ]
    then
        break
    else
        # Rename the session we are making
        name="${dirs_list[$num_dirs]}/$name"
        (( num_dirs-- ))
        (( dir_depth++ ))
    fi
done

tmux new -s "$name" -e "$dir_env_var=$directory"
exit
