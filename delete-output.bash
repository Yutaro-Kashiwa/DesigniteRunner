
#!/bin/bash
# Check if project.txt exists
if [[ ! -f projects.txt ]]; then
  echo "projects.txt not found!"
  exit 1
fi
target_count=$1


cd outputs
count=1
# Read the repository name from projects.txt
while IFS= read -r repo_name; do
  echo "--$count-----------------------"
  if [[ -n "$target_count" && $count -eq $target_count ]]; then
    echo "Processing repository: $repo_name"
    ((count++))
  else
    echo "SKIP: $repo_name"
    ((count++))
    continue
  fi

  # Clone the repository
  if [[ -d "$repo_name" ]]; then
  	echo "  Repository exists"
  	rm -Rf $repo_name
  fi
done < projects.txt

