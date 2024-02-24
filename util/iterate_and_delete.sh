#!/usr/bin/env bash
# Iterate over files in directory and for each file decide if you want to delete it
# Can be used to clean a downloads folder

usage()
{
cat << EOF
    Usage: $0 [-h] <-d directory> [-m secondary directory]

    Iterate over files in a directory and decide which to delete
    Mark a file to be moved to specified directory for further sorting

    -h Show this help text
    -d Choose the directory to delete the files from
    -m Choose the directory to which files can be moved
EOF
exit
}

prase_params()
{
    while getopts "h:d:m" opt; do
        case ${opt} in
            h)
                usage
                ;;
            d)
                DIRECTORY=${OPTARG}
                ;;
            m)
                SECONDARY_DIRECTORY=${OPTARG}
                ;;
            \?)
                usage
                ;;
            :)
                ;;
        esac
    done

    if [[ -z ${DIRECTORY} ]]; then
        echo "Missing required arguments" >&2
        usage
    fi
}

prase_params "$@"

STARTING_DIR=$(pwd)

cd "${DIRECTORY}" || exit
for FILE in *; do
    # Iterate over files and let user decide if to mark file for deletion or to be moved
    echo "$FILE" ;
    done

# Display all files that will be deleted

# Ask for confirmation
    # Otherwise, exit the script and make no changes

# Display all files that will be moved

# Ask for confirmation
    # Otherwise, exit the script and make no changes

# List all the freed space

# Return to the directory the script was called from
cd "${STARTING_DIR}" || exit