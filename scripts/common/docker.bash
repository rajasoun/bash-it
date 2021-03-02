#!/usr/bin/env bash

function docker_space_before(){
  CURRENTSPACE=$(docker system df)
  echo "Current Docker Space:" 
  echo -e "$CURRENTSPACE"
}

function docker_find (){
  REMOVEIMAGES=$(docker images | grep " [days|months|weeks]* ago" | awk '{print $3}')

  echo "Listing images that needs to be cleaned up:" 
  echo -e "$REMOVEIMAGES"
}

function docker_clean_images(){
  echo "Cleaning images" 
  docker rmi \
    $(docker images --filter "dangling=true" -q --no-trunc) \
    2>/dev/null || echo "No more dangling images to remove."
  # Always remove untagged images
  docker rmi \
    $(docker images | grep "<none>" | awk '{print $3}') \
    2>/dev/null || echo "No untagged images to delete."
}

function docker_space_after(){
  CURRENTSPACE=$(docker system df)
  echo "Current Docker Space, after clean up:" 
  echo -e "$CURRENTSPACE"
}

function docker_clean(){
  docker_space_before
  docker_find
  docker_clean_images
  docker_space_after
}
