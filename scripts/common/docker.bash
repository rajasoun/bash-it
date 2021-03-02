#!/usr/bin/env bash

function docker_space_before(){
  CURRENTSPACE=`docker system df`
  echo "Current Docker Space:" 
  echo $CURRENTSPACE 
}

function docker_find (){
  echo "#####################################################################" >> $log
  echo "Finding images" 
  echo "#####################################################################" >> $log
  REMOVEIMAGES=`docker images | grep " [days|months|weeks]* ago" | awk '{print $3}'`

  echo "Listing images that needs to be cleaned up" 
  echo $REMOVEIMAGES 
}

function docker_clean_images(){
  echo "#####################################################################" >> $log
  echo "Cleaning images" 
  echo "#####################################################################" >> $log
  docker rmi ${REMOVEIMAGES}
}

function docker_space_after(){
  CURRENTSPACE=`docker system df`
  echo "Current Docker Space, after clean up:" 
  echo $CURRENTSPACE 
}

function docker_clean(){
  docker_space_before
  docker_find
  docker_cleanup
  docker_space_after
}
