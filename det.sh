#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Check for required tools
REQUIRED_TOOLS=("docker" "jq")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed. Please install it before running the script." 1>&2
        exit 1
    fi
done

# Default configuration file
CONFIG_FILE="config.json"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -L                Enable server (listening) mode for DET."
    echo "  -c <config_file>  Path to the configuration file (default: ./config.json)."
    echo "  -f <file>         File to exfiltrate (mounted as read-only)."
    echo "  -d <directory>    Directory to exfiltrate (mounted as read-write)."
    echo "  -p <plugin>       Plugins to use (e.g., dns, icmp)."
    echo "  -h, --help        Display this help message."
    echo
    exit 0
}

# Parse script arguments
DET_PARAMS=()
MOUNT_OPTIONS=""
CUSTOM_CONFIG=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -L)
            DET_PARAMS+=("-L")
            ;;
        -c)
            CONFIG_FILE="$(realpath "$2")"
            if [ ! -f "$CONFIG_FILE" ]; then
                echo "Error: Configuration file $CONFIG_FILE not found." 1>&2
                exit 1
            fi
            DET_PARAMS+=("-c" "/opt/DET/config.json")
            shift
            ;;
        -f)
            FILE="$(realpath "$2")"
            if [ ! -f "$FILE" ]; then
                echo "Error: File $FILE does not exist or is not a regular file." 1>&2
                exit 1
            fi
            DET_PARAMS+=("-f" "/data/$(basename "$FILE")")
            MOUNT_OPTIONS+="-v $(realpath "$FILE"):/data/$(basename "$FILE"):ro "
            shift
            ;;
        -d)
            DIRECTORY="$2"
            if [ ! -d "$DIRECTORY" ]; then
                echo "Error: Directory $DIRECTORY does not exist." 1>&2
                exit 1
            fi
            DET_PARAMS+=("-d" "/data/$(basename "$DIRECTORY")")
            MOUNT_OPTIONS+="-v $(realpath "$DIRECTORY"):/data/$(basename "$DIRECTORY"):rw "
            shift
            ;;
        -p)
            DET_PARAMS+=("-p" "$2")
            shift
            ;;
        *)
            echo "Error: Unknown option $1" 1>&2
            usage
            ;;
    esac
    shift
done

# Fallback to mounting the current directory if no file or directory is specified
if [[ -z "$MOUNT_OPTIONS" ]]; then
    MOUNT_OPTIONS+="-v $(pwd):/data:rw "
fi

# Check if the Docker image exists
IMAGE_NAME="det-docker"
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "Building the Docker image for DET..."
    if docker build -t "$IMAGE_NAME" .; then
        echo "Docker image built successfully."
    else
        echo "Docker image build failed. Exiting." 1>&2
        exit 1
    fi
fi

# Run the container
echo "Running DET with the following arguments: ${DET_PARAMS[*]}"
docker run -ti --rm --privileged --network host --cap-add=NET_ADMIN --cap-add=NET_RAW \
    -v "$CONFIG_FILE:/opt/DET/config.json:ro" \
    $MOUNT_OPTIONS \
    "$IMAGE_NAME" "${DET_PARAMS[@]}"
