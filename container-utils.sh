#!/bin/bash

function help(){
echo "USAGE $0 [argument]"
echo "  -a: list all containers"
echo "  -u: list running containers"
echo "  -f: keep first container, remove others"
echo "  -l: keep last container, remove others"
echo "  -s: stop all running containers"
}

#default function to remove 'CONTAINER' which 
#is first word in column
function removeheader(){
 echo ${@/CONTAINER/ }
}

#given an array of containers remove them
function remove(){
 for i in "$@"
 do
   echo "removing container: "$i
   docker rm $i
 done
}

#list all containers
function listall(){
 echo `docker ps -a | awk '{print $1}'`
}

#list running containers
function listrunning(){
 echo `docker ps | awk '{print $1}'`
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

#stop running containers
function stop(){
 for i in "$@"
 do
   echo "stop container: "$i
   docker stop $i
 done
}

#Confirm at least one argument is supplied 
#otherwise exit with help message
if [ -z $1 ]; then
 help
 exit
fi

while getopts ":aflsu" opt; do
  case ${opt} in
    a)
      #list all containers
      _value=$(listall)
      echo $(removeheader $_value) >&2
      ;;
    u)
      #list running containers
      _value=$(listrunning)
      echo $(removeheader $_value)
      ;;
    f)
      #keep first container remover rest
      _value=$(listall)
      _value=$(removeheader $_value)
      _value=$(keepfirst $_value)
      remove $_value
      ;;
     l)
       #keep last container remove rest
       _value=$(listall)
       _value=$(removeheader $_value)
       _value=$(keeplast $_value)
       remove $_value
      ;;
     s)
       #stop all running containers
       _value=$(listrunning)
       _value=$(removeheader $_value)
       stop $_value
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      ;;
  esac
done
