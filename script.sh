#!/bin/bash

versions=(
  1.5.57 1.6.42 1.7.14 # last versions of each minor release
  1.6.1 1.6.10 1.6.20 1.6.30 # increments of 10
  1.6.15 1.6.12 1.6.11 # find the breaking point
)

function get_quarto {
  version=$1
  quarto_path=$2
  if [ ! -f $quarto_path ]; then
    echo "Downloading Quarto $version"
    quarto_tar_url=https://github.com/quarto-dev/quarto-cli/releases/download/v$version/quarto-$version-linux-amd64.tar.gz
    wget $quarto_tar_url -O /tmp/quarto-$version.tar.gz
    mkdir -p $HOME/.local/share/quarto-$version
    tar -xzf /tmp/quarto-$version.tar.gz -C $HOME/.local/share
    rm /tmp/quarto-$version.tar.gz
  fi
}

for version in "${versions[@]}"; do
  qmd_file=render-$version.qmd
  html_file=render-$version.html

  # skip if html already exists
  if [ -f $html_file ]; then
    continue
  fi
  
  echo "Rendering with Quarto $version"

  # determine quarto path
  quarto_path=$HOME/.local/share/quarto-$version/bin/quarto
  get_quarto "$version" "$quarto_path"

  # copy template
  cp example.qmd $qmd_file

  # change title in header
  sed -i "s/Mermaid in Quarto/Mermaid in Quarto $version/g" $qmd_file
  
  # render using this version of quarto
  $quarto_path render $qmd_file
done

