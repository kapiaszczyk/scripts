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
    while getopts "h:d:m:" opt; do
        case ${opt} in
            h)
                usage
                ;;
            d)
                DIRECTORY=${OPTARG}
                ;;
            m)
                SECONDARY_DIRECTORY=${OPTARG}
                echo "Secondary directory: ${SECONDARY_DIRECTORY}"
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

# Declaring variables
STARTING_DIR=$(pwd)
declare -a FILES_TO_DELETE=()
declare -a FILES_TO_MOVE=()
SPACE_RECLAIMED=0

cd "${DIRECTORY}" || exit

for FILE in *; do
    # Iterate over files and let user decide if to mark file for deletion or to be moved and  move the path to a list
    echo "$FILE" "Size: $(stat -c %s "${FILE}")" "Last modified: $(stat -c %y "${FILE}")"
    read -r -p "Delete, move, or skip? (d/m/s): " ACTION
    case ${ACTION} in
        d)
            FILES_TO_DELETE+=("${FILE}")
            SPACE_RECLAIMED=$((SPACE_RECLAIMED + $(stat -c %s "${FILE}")))
            ;;
        m)
            if [[ -z ${SECONDARY_DIRECTORY} ]]; then
                echo "No secondary directory specified" >&2
                exit
            fi
            FILES_TO_MOVE+=("${FILE}")
            ;;
        s)
            continue
            ;;
        *)
            echo "Invalid option" >&2
            exit
            ;;
    esac

    done

# Display all files that will be deleted
if  [[ ${#FILES_TO_DELETE[@]} -eq 0 ]]; then
    echo "No files to delete"
else
    echo "Files to be deleted:"
    for i in  "${FILES_TO_DELETE[@]}"; do
        echo "$i";
    done;
fi

# Ask for confirmation
    # Otherwise, exit the script and make no changes
# If there is no files to delete, skip this step
if [[ ${#FILES_TO_DELETE[@]} -eq 0 ]]; then
    echo "No files to delete"
else
    read -r -p "Are you sure you want to delete these files? (y/n): " CONFIRMATION
    case ${CONFIRMATION} in
        y)
            # Delete files
            for i in  "${FILES_TO_DELETE[@]}"; do
                rm "${i}"
            done
            ;;
        n)
            echo "No changes made"
            exit
            ;;
        *)
            echo "Invalid option" >&2
            exit
            ;;
    esac
fi


# Display all files that will be moved
if [[ ${#FILES_TO_MOVE} -eq 0 ]] && [[ -z ${SECONDARY_DIRECTORY} ]]; then
    echo "No files to move"
fi
if [[ -n ${SECONDARY_DIRECTORY} ]] && [[ ${#FILES_TO_MOVE[@]} -ne 0 ]]; then
    echo "Files to be moved:"
    for i in  "${FILES_TO_MOVE[@]}"; do
        echo "$i";
    done;
fi

# Ask for confirmation
    # Otherwise, exit the script and make no changes
if [[ -n ${SECONDARY_DIRECTORY} ]] && [[ ${#FILES_TO_MOVE[@]} -ne 0 ]]; then
    read -r -p "Are you sure you want to move these files? (y/n): " CONFIRMATION
    case ${CONFIRMATION} in
        y)
            # Move files to secondary directory
            if [[ -n ${SECONDARY_DIRECTORY} ]]; then
                for i in  "${FILES_TO_MOVE[@]}"; do
                    mv "${i}" "${SECONDARY_DIRECTORY}"
                done
            fi
            # Delete files
            for i in  "${FILES_TO_DELETE[@]}"; do
                rm "${i}"
            done
            ;;
        n)
            echo "No changes made"
            exit
            ;;
        *)
            echo "Invalid option" >&2
            exit
            ;;
    esac
fi

# List the reclaimed space
echo "Space reclaimed: ${SPACE_RECLAIMED} bytes"

# Return to the directory the script was called from
cd "${STARTING_DIR}" || exit