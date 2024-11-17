
#!/bin/bash
# Check if project.txt exists
if [[ ! -f projects.txt ]]; then
  echo "projects.txt not found!"
  exit 1
fi
target_count=$1
# Create a directory to clone repositories
mkdir -p cloned_repos

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
  cd cloned_repos || exit
  # Clone the repository
  if [[ -d "$repo_name" ]]; then
  	echo "  Repository already exists"
  else
   	echo "  Cloning starts"
   	echo https://github.com/$repo_name
 	git clone https://github.com/$repo_name $repo_name
  fi

  # Check if the repository was cloned successfully
  if [[ -d "$repo_name" ]]; then
  	cd "$repo_name"
  	sha_dir='../../../sha/'$repo_name
  	echo $sha_dir
    if [[ -d "$sha_dir" ]]; then
	  echo "  Sha directory already exists"
    else
  	  mkdir -p $sha_dir
    fi
    git reset --hard origin/HEAD
    git config pull.rebase false
    git pull
    git pull origin main
    git pull origin master
    git reset --hard origin/HEAD

    # Get the list of commit SHAs
    git log --pretty=format:"%H" > "$sha_dir"/list.txt
    
    # Go back to the cloned_repos directory
    cd ../../..
  else
    echo "Failed to clone repository: $repo_name"
    exit
  fi
done < projects.txt

echo "SHA lists have been created for each repository."