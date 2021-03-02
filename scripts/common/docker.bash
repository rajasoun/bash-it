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
  docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
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
