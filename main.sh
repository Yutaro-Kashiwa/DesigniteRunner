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
  echo $count
  if [[ -n "$target_count" && $count -eq $target_count ]]; then
    echo "RUN"
    ((count++))
  else
    echo "SKIP"
    ((count++))
    continue
  fi
  cd cloned_repos || exit
  echo "-------------------------"
  echo "Processing repository: $repo_name"
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
  else
    echo "ERROR: Failed to clone repository: $repo_name"
    exit
  fi
  cd ../../..

  sha_dir='sha/'$repo_name



  echo $sha_dir
  if [[ -d "$sha_dir" ]]; then
    sha_file=$sha_dir/list.txt
  else
	echo "  ERROR: Sha directory does not exist"
  	exit
  fi
  
  #Fetch file
  
  while IFS= read -r sha; do
  	output_dir="outputs/$repo_name/$sha"
  	echo $output_file
  	
  	if [[ -d "$output_dir" ]]; then
      echo "this sha is already analyzed"
      continue
    fi
    if [[ -d "$output_dir.tmp" ]]; then
      echo "this sha is being analyzed"
      continue
    fi
    mkdir $output_dir.tmp
  	echo "Checkout:" $sha
  	cd cloned_repos/$repo_name
  	git reset --hard
    git checkout $sha
    current_sha=$(git rev-parse HEAD)
    if [ "$current_sha" == "$sha" ]; then
      echo "SHA matches: $current_sha"
    else
      echo "SHA does not match. "
      echo "  Tried checkout SHA: $sha"
      echo "  Current SHA: $current_sha"
      mv $output_dir.tmp $output_dir.checkout.error
      continue
    fi

    cd ../../..
    #Designiteを走らせる
    # java -jar Designite.java
    java -jar ./DesigniteJava.jar -i cloned_repos/$repo_name -o $output_dir.tmp

    #出力ファイルをproject/sha.csvにする

    # mv XXX outputs/$repo_name/$sha.txt
    mv $output_dir.tmp $output_dir

  done < $sha_file
  
  # Go back to the cloned_repos directory
  cd ../../..

done < projects.txt


