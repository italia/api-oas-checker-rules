#!/bin/bash

# Function to increase the version number
increase_version() {
    local version=$1
    # Split the version string into an array using '.' as the delimiter
    IFS='.' read -r -a parts <<< "$version"
    parts=("${parts[@]}")  # Create an array
    # Convert the array elements to integers
    parts=($(printf '%d\n' "${parts[@]}"))

    # Reverse the array using awk
    parts=($(printf '%s\n' "${parts[@]}" | awk '{lines[NR] = $0} END {for (i = NR; i > 0; i--) print lines[i]}'))

    # Increment the least significant part of the version number
    parts[0]=$((parts[0] + 1))
    
    # Propagate the carry if necessary
    for ((i=0; i<${#parts[@]}-1; i++)); do
        if [[ ${parts[i]} -ge 10 ]]; then
            parts[i]=0
            parts[i+1]=$((parts[i+1] + 1))
        fi
    done
    
    # Reverse the array back to the correct order using awk
    parts=($(printf '%s\n' "${parts[@]}" | awk '{lines[NR] = $0} END {for (i = NR; i > 0; i--) print lines[i]}'))

    # Join the parts into a new version string
    local new_version=$(IFS=.; echo "${parts[*]}")
    echo "$new_version"
}

# Function to check if a version string is all zeros
is_all_zeros() {
    local version=$1
    # Replace all dots with nothing and check if the result is all zeros
    [[ $(echo "$version" | tr -d '.') =~ ^0+$ ]]
}

# Main function
main() {
    local RULES_CHANGED=$1
    local LATEST_TAG=${2:-"0.0"}  # If LATEST_TAG is not defined, use "0.0"

    if [[ "$RULES_CHANGED" == "true" ]]; then
        new_version=$(increase_version "$LATEST_TAG")
        echo "$new_version"
    else
        if is_all_zeros "$LATEST_TAG"; then
            new_version=$(increase_version "$LATEST_TAG")
            echo "$new_version"
        else
            echo "$LATEST_TAG"
        fi
    fi
}

RULES_CHANGED=$1
LATEST_TAG=$2
main "$RULES_CHANGED" "$LATEST_TAG"