#!/bin/bash

UPDATE_SET="false"
DELETE_SET="false"
DB_USER_SET="false"
DB_PASSWD_SET="false"

UPDATE="false"
ENTITY_ID_DROP=""
DB_USER=""
DB_PASSWD=""
DB_NAME="drupaldb"

source credentials.sh
source common.sh
ensure_fresh_access_token

usage() {
  printf "Usage: fusionsync.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD\n"
}

# attempt connection to db with supplied credentials
db_conn_check() {
  mysql -u "$DB_USER" -p"$DB_PASSWD" -e "use $1"
  echo $?
}

get_db_data() {
  mysql --batch --raw -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -sse \
  "SELECT country.field_country_value, \
  field_data_field_affiliation.field_affiliation_value, \
  field_data_field_operators.field_operators_value, \
  field_data_field_signed_mou.field_signed_mou_value, \
  field_data_field_saml.field_saml_value, \
  field_data_field_saml_complete.field_saml_complete_value, \
  field_data_field_edugain.field_edugain_value, \
  field_data_field_edugain_complete.field_edugain_complete_value, \
  field_data_field_eduroam.field_eduroam_value, \
  field_data_field_eduroam_complete.field_eduroam_complete_value, \
  field_data_field_progress.field_progress_value, \
  field_data_field_flagurl.field_flagurl_value \
  FROM field_data_field_country AS country \
  LEFT JOIN field_data_field_affiliation ON country.entity_id = field_data_field_affiliation.entity_id \
  LEFT JOIN field_data_field_operators ON country.entity_id = field_data_field_operators.entity_id \
  LEFT JOIN field_data_field_signed_mou ON country.entity_id = field_data_field_signed_mou.entity_id \
  LEFT JOIN field_data_field_saml ON country.entity_id = field_data_field_saml.entity_id \
  LEFT JOIN field_data_field_saml_complete ON country.entity_id = field_data_field_saml_complete.entity_id \
  LEFT JOIN field_data_field_edugain ON country.entity_id = field_data_field_edugain.entity_id \
  LEFT JOIN field_data_field_edugain_complete ON country.entity_id = field_data_field_edugain_complete.entity_id \
  LEFT JOIN field_data_field_eduroam ON country.entity_id = field_data_field_eduroam.entity_id \
  LEFT JOIN field_data_field_eduroam_complete ON country.entity_id = field_data_field_eduroam_complete.entity_id \
  LEFT JOIN field_data_field_progress ON country.entity_id = field_data_field_progress.entity_id \
  LEFT JOIN field_data_field_flagurl ON country.entity_id = field_data_field_flagurl.entity_id;"
}

encode_space() {
  echo "$1" | sed 's/ /%20/g'
}

escape_chars() {
  echo "$1" | sed -e 's/%/%25/g' -e "s/'/\\\'/g" -e 's/NULL//g'
}

if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    -u | --update )
      if [ "$DELETE_SET" == "false" ]; then
        UPDATE="true"
        UPDATE_SET="true"
      else
        usage
        exit 1
      fi
      ;;
    -d | --delete )
      shift
      if [ "$UPDATE_SET" == "false" ]; then
        ENTITY_ID_DROP="$1"
        DELETE_SET="true"
      else
        usage
        exit 1
      fi
      ;;
    --user )
      shift
      DB_USER="$1"
      if [ "$DB_USER" == "" ]; then
        printf "Invalid user '$DB_USER'\n"
        usage
        exit 1
      fi
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

if [[ $(db_conn_check $DB_NAME) == 1 ]]; then
  # failure
  printf "Failed to connect to database\n"
  usage
  exit 1
fi

key="AIzaSyBPmZQT3CpatiuKpr-dXUEhAjeDTha1Syo"
resourceID="10wEN3u3XsSdjmyZjlSvTqe8mNlpQWOjhzLlVp0rV"
IFS=$'\t'; get_db_data | while read -r country affiliation operators signed_mou saml saml_complete \
  edugain edugain_complete eduroam eduroam_complete progress flag_url; do
  if [ "$UPDATE" == "true" ]; then
    SQL_QUERY=$(encode_space "SELECT ROWID FROM ${resourceID} WHERE Location='$(encode_space ${country})'")
    status_code=$(curl -s -H "Content-Length:0" -X POST \
      "https://www.googleapis.com/fusiontables/v2/query?sql=${SQL_QUERY}&key=${key}&alt=csv" \
      | sed -n '2p')
    if [ ! "$status_code" == "" ] || [ ! -z "$status_code" ]; then
      # row exists, must delete first
      SQL_QUERY=$(encode_space "DELETE FROM ${resourceID} WHERE ROWID='${status_code}'")
      curl -H "Content-Length:0" -H "Authorization: Bearer $access_token" \
        -X POST "https://www.googleapis.com/fusiontables/v2/query?sql=${SQL_QUERY}&alt=csv"
    fi
    SQL_QUERY=$(encode_space "INSERT INTO ${resourceID} \
      ('Location'%2C'Affiliation'%2C'Operators'%2C'SAML'%2C'eduGAIN'%2C\
      'eduroam'%2C'Signed MoU'%2C'Progress'%2C'FlagURL'%2C\
      'SAML-complete'%2C'eduGAIN-complete'%2C'eduroam-complete') \
      VALUES ('$(escape_chars ${country})'%2C\
      '$(escape_chars ${affiliation})'%2C\
      '$(escape_chars ${operators})'%2C\
      '$(escape_chars ${saml})'%2C\
      '$(escape_chars ${edugain})'%2C\
      '$(escape_chars ${eduroam})'%2C\
      '$(escape_chars ${signed_mou})'%2C\
      '$(escape_chars ${progress})'%2C\
      '$(escape_chars ${flag_url})'%2C\
      '$(escape_chars ${saml_complete})'%2C\
      '$(escape_chars ${edugain_complete})'%2C\
      '$(escape_chars ${eduroam_complete})')")
    curl -H "Content-Length:0" -H "Authorization: Bearer $access_token" -X POST \
      "https://www.googleapis.com/fusiontables/v2/query?sql=${SQL_QUERY}&alt=csv"
  fi
done
unset IFS
exit
