#!/usr/bin/env bash
# chmod +x getmodel.sh

set -e

model="llava-fastvithd_0.5b_stage3_llm.fp16"
base_url="https://ml-site.cdn-apple.com/datasets/fastvlm"

dest_dir="Camera/model"
mkdir -p "$dest_dir"
tmp_dir=$(mktemp -d)

tmp_zip_file="${tmp_dir}/${model}.zip"
tmp_extract_dir="${tmp_dir}/${model}"
mkdir -p "$tmp_extract_dir"

echo -e "\nDownloading '${model}' model ...\n"
wget -q --progress=bar:noscroll --show-progress -O "$tmp_zip_file" "$base_url/$model.zip"

echo -e "\nUnzipping model..."
unzip -q "$tmp_zip_file" -d "$tmp_extract_dir"

echo -e "\nCopying model files to destination directory..."
cp -r "$tmp_extract_dir/$model"/* "$dest_dir"

echo -e "\nModel downloaded and extracted to '$dest_dir'"

cleanup() { 
    rm -rf "$tmp_dir"
}

# Cleanup download directory on exit
trap cleanup EXIT INT TERM
