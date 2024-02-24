#!/usr/bin/env bash
# Build and run a Docker image

usage()
{
    cat<<EOF
    Usage: $0 [-h] [-s source directory] [-n image name] [-p port]

    Build and run a Docker image

    -h  Show this help text
    -s  Source directory - where Maven build is run from
    -n  Image name
    -p  Port to expose
EOF
    exit
}

prase_params() {
    while getopts "hs:n:p:" opt; do
        case ${opt} in
            h)
                usage
                ;;
            s)
                SOURCE_DIR=${OPTARG}
                ;;
            n)
                IMAGE_NAME=${OPTARG}
                ;;
            p)
                PORT=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -${OPTARG}" >&2
                usage
                ;;
            :)
                echo "Option -${OPTARG} requires an argument." >&2
                usage
                ;;
        esac
    done

    if [[ -z ${SOURCE_DIR} ]] || [[ -z ${IMAGE_NAME} ]]; then
        echo "Missing required arguments" >&2
        usage
    fi
}

prase_params "$@" # Pass all arguments to the function

# Save current directory
CURRENT_DIR=$(pwd)

# Go to source directory and run Maven build
cd "${SOURCE_DIR}" || exit
mvn clean package

# In case of failure, exit
if [[ $? -ne 0 ]]; then
    echo "Maven build failed" >&2
    cd "${CURRENT_DIR}" || exit
    exit 1
fi

# Build Docker image
docker build -t "${IMAGE_NAME}" .

# In case of failure, exit
if [[ $? -ne 0 ]]; then
    echo "Docker build failed" >&2
    cd "${CURRENT_DIR}" || exit
    exit 1
fi

# Run Docker image
# If ports are specified, expose them
if [[ -z ${PORT} ]]; then
    docker run -d "${IMAGE_NAME}"
else
    docker run -d -p "${PORT}":"${PORT}" "${IMAGE_NAME}"
fi

# In case of failure, exit
if [[ $? -ne 0 ]]; then
    echo "Docker run failed" >&2
    cd "${CURRENT_DIR}" || exit
    exit 1
fi

# Go back to original directory
cd "${CURRENT_DIR}" || exit
