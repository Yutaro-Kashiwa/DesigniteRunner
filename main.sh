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
  # 並列処理用プログラム
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
    mkdir -p "outputs/$repo_name"
    mkdir -p $output_dir.tmp
  	echo "Checkout:" $sha
  	cd cloned_repos/$repo_name
  	git reset --hard
	git clean -fd
	# Attempt checkout and capture its output (stdout and stderr)
        checkout_output_and_error=$(git checkout "$sha" 2>&1)
        checkout_status=$? # Get the exit status of the checkout command

        if [ $checkout_status -eq 0 ]; then
          echo "Checkout succeeded."
        else
          # Initial checkout failed
          echo "Initial checkout failed for revision $sha."
          echo "Error output: $checkout_output_and_error"

          # Check if the failure was due to index.lock
          if echo "$checkout_output_and_error" | grep -q "index.lock"; then
            echo "Detected .git/index.lock issue. Attempting to remove lock file and retry checkout..."
            rm -f .git/index.lock # Remove the lock file (-f to suppress error if not found)
            
            # Retry checkout
            echo "Retrying checkout for $sha..."
            checkout_output_and_error_retry=$(git checkout "$sha" 2>&1) # Capture output of retry
            checkout_status_retry=$? # Get exit status of retry

            if [ $checkout_status_retry -eq 0 ]; then
              echo "Checkout succeeded on retry."
            else
              # Checkout still failed after removing index.lock
              echo "Error: Checkout STILL failed for revision $sha after attempting to remove .git/index.lock." >&2
              echo "Error output on retry: $checkout_output_and_error_retry"
              # cd back to the main script directory before mv
              cd ../../.. 
              if [[ -d "$output_dir.tmp" ]]; then
                mv "$output_dir.tmp" "$output_dir.checkout.error"
              else
                echo "Error: $output_dir.tmp does not exist for $sha, cannot rename for checkout error."
              fi
              exit 1
            fi
          else
            # Checkout failed for a reason other than index.lock
            echo "Error: Checkout failed for revision $sha (not a .git/index.lock issue)." >&2
            # cd back to the main script directory before mv
            cd ../../..
            if [[ -d "$output_dir.tmp" ]]; then
              mv "$output_dir.tmp" "$output_dir.checkout.error"
            else
              echo "Error: $output_dir.tmp does not exist for $sha, cannot rename for checkout error."
            fi
            exit 1
          fi
        fi
    
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
    echo "-run start-----"
    echo $output_dir.tmp
    bash main-command.sh cloned_repos/$repo_name $output_dir.tmp
    #出力ファイルをproject/sha.csvにする
    echo "-run finish-----"

    # mv XXX outputs/$repo_name/$sha.txt
    mv $output_dir.tmp $output_dir

  done < $sha_file
  # Go back to the cloned_repos directory
  cd ../../..
done < projects.txt


