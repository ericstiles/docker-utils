#!/bin/bash

function help(){
 echo "USAGE $0 [argument]"
 echo "  -a: list images"
 echo "  -f: keep first image, remove others"
 echo "  -l: keep last image, remove others"
 echo "  -z: remove all images"
 echo "  -1: drop first image"
}

#default function to remove 'CONTAINER' which 
#is first word in column
function removeheader(){
 echo ${@/IMAGE/ }
}

#given an array of containers remove them
function remove(){
 for i in "$@"
 do
   echo "removing image: "$i
   docker rmi $i
 done
}

#list images
function listall(){
 echo `docker images | awk '{print $3}'`
}

#remove first image only
function removefirst(){
  echo $1
}

#remove specific image
function removespecific(){
  opt=$1
  printf $opt
  printf ":"
  array=$@
  printf $@
  printf ":"
  #echo -e ${array[opt]}
  # echo $@
  #echo -e $array
  # array=("${array[@]:1}")
  # echo $array
  # echo $array
}

#keep only first image from all containers
function keepfirst(){
 array="$@"
 echo ${array#* }
}

#keep only last image from all containers
function keeplast(){
 _value="$@"
 echo ${_value% *}
}

#Confirm at least one argument is supplied 
#otherwise exit with help message
if [ -z $1 ]; then
 help
 exit
fi

# while getopts ":aflz123" opt; do
while getopts ":aflz1" opt; do
  case ${opt} in
    a)
      #list all images
      _value=$(listall)
      echo $(removeheader $_value) >&2
      ;;
    f)
      #keep first image remover rest
      _value=$(listall)
      _value=$(removeheader $_value)
      _value=$(keepfirst $_value)
      remove $_value
      ;;
     l)
       #keep last image remove rest
       _value=$(listall)
       _value=$(removeheader $_value)
       _value=$(keeplast $_value)
       remove $_value
      ;;
     z)
       #remove all images
       _value=$(listall)
       _value=$(removeheader $_value)
       remove $_value
       ;;
     [1-9])
       #remove all images
       _value=$(listall)
       _value=$(removeheader $_value)
       _value=$(removefirst $_value)
       remove $_value
       ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      ;;
  esac
done
