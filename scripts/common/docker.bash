#!/usr/bin/env bash

function docker_space_before(){
  echo "Current Docker Space:" 
  CURRENTSPACE=$(docker system df)
  echo -e "$CURRENTSPACE"
}

function docker_find (){
  echo "Listing images that needs to be cleaned up:" 
  REMOVEIMAGES=$(docker images | grep " [days|months|weeks]* ago" | awk '{print $3}' || echo "None")
  echo -e "$REMOVEIMAGES"
}

function docker_clean_images(){
  echo "Cleaning images" 
  docker rmi \
    "$(docker images --filter "dangling=true" -q --no-trunc)" \
    2>/dev/null || echo "No dangling images to remove."
  # Always remove untagged images
  docker rmi \
    "$(docker images | grep "<none>" | awk '{print $3}')" \
    2>/dev/null || echo "No untagged images to delete."
}

function docker_space_after(){
  echo "Current Docker Space, after clean up:" 
  CURRENTSPACE=$(docker system df)
  echo -e "$CURRENTSPACE"
}

#ToDo: Implement logic for performing actions like build, release or clean on all Dockerfiles 
function perform_docker_build_action(){
  action=$1
  select_dir_containing_file "Dockerfile"
  cd "docker-shells/$FILE_DIR" && make "$action" && cd - || return
}

function docker_clean(){
  docker_space_before
  docker_find
  docker_clean_images
  docker_space_after
}
