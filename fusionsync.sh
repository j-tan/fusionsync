#!/bin/bash

UPDATE_SET="false"
DELETE_SET="false"
DB_USER_SET="false"
DB_PASSWD_SET="false"

UPDATE="false"
ENTITY_ID_DROP=""
DB_USER=""
DB_PASSWD=""

usage() {
  printf "Usage: map_update.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD\n"
}

if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    -u | --update )
      if [ DELETE_SET == "false" ]; then
        UPDATE="true"
      else
        usage
        exit 1
      fi
      ;;
    -d | --delete )
      shift
      if [ UPDATE_SET == "false" ]; then
        ENTITY_ID_DROP="$1"
      else
        usage
        exit 1
      fi
      ;;
    --user )
      shift
      DB_USER="$1"
      ;;
    --password )
      shift
      DB_PASSWD="$1"
      ;;
    * )
      printf "Unknown argument '$1'\n"
      usage
      exit 1
      ;;
  esac
  shift
done
exit