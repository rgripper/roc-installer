#!/bin/bash

# Set export_path variable
export_path="$HOME/roc"

# Determine the system architecture and operating system
arch=$(uname -m)
os=$(uname -s)

# Define download URLs based on architecture and operating system
case "$os" in
    Linux)
        if [ "$arch" = "x86_64" ]; then
            url="https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-linux_x86_64-latest.tar.gz"
        elif [ "$arch" = "aarch64" ]; then
            url="https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-linux_arm64-latest.tar.gz"
        else
            echo "Unsupported architecture: $arch"
            exit 1
        fi
        ;;
    Darwin)
        if [ "$arch" = "x86_64" ]; then
            url="https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-macos_x86_64-latest.tar.gz"
        elif [ "$arch" = "arm64" ]; then
            url="https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-macos_apple_silicon-latest.tar.gz"
        else
            echo "Unsupported architecture: $arch"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: $os"
        exit 1
        ;;
esac

echo "Detected architecture: $arch"
echo "Detected operating system: $os"
echo "Download URL set to: $url"

# Create a temporary directory
tmp_dir=$(mktemp -d)
echo "Created temporary directory: $tmp_dir"

# Download and extract the tar.gz file in the temporary directory
echo "Downloading and extracting the tar.gz file..."
curl -L $url | tar -xz -C "$tmp_dir"

# Find the extracted directory
extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name 'roc_nightly-*' -print -quit)
echo "Extracted directory: $extracted_dir"

# Remove existing ~/roc directory if it exists and move the new contents
if [ -d "$export_path" ]; then
    echo "Removing existing $export_path directory..."
    rm -rf "$export_path"
fi

echo "Moving new files to $export_path..."
mkdir -p "$export_path"
mv "$extracted_dir"/* "$export_path/"

# Clean up the temporary directory
echo "Cleaning up temporary directory..."
rm -rf "$tmp_dir"

# Confirm the operation
echo "Updated $export_path with the latest files."

# Set the profile file based on the current shell
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        profile_file="$HOME/.bash_profile"
    elif [ -f "$HOME/.bash_login" ]; then
        profile_file="$HOME/.bash_login"
    elif [ -f "$HOME/.bashrc" ]; then
        profile_file="$HOME/.bashrc"
    else
        profile_file="$HOME/.profile"
    fi
elif [ -n "$ZSH_VERSION" ]; then
    profile_file="$HOME/.zshrc"
else
    echo "Unsupported shell."
    exit 1
fi

# Check if the export path is already in the profile file or PATH
if grep -qF "$export_path" "$profile_file" || [[ ":$PATH:" == *":$export_path:"* ]]; then
    echo "The export path is already set in $profile_file or PATH. Skipping addition."
else
    # Add export statement to the appropriate profile file
    echo "Adding export statement to $profile_file"
    echo -e "\nexport PATH=\$PATH:$export_path" >> "$profile_file"

    echo "Reload the shell to apply changes."
fi
