#!/usr/bin/bash

cd results

for folder in *-*; do
  if [ -d "$folder" ]; then
    cd "$folder"
    param=$(echo "$folder" | cut -d'-' -f1)

    for file in t-*.csv; do
      if [ -f "$file" ]; then
        threads=$(echo "$file" | cut -d'-' -f2 | cut -d'.' -f1)
        output="${file%.csv}.png"
        ../draw.py -i "$file" -o "$output" --y-title "$param" -t "number of threads = $threads"
      fi
    done

    cd ..
  fi
done
