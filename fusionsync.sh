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

usage() {
  printf "Usage: fusionsync.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD\n"
}

# attempt connection to db with supplied credentials
db_conn_check() {
  mysql -u "$DB_USER" -p"$DB_PASSWD" -e "use $1"
  echo $?
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
  LEFT JOIN field_data_field_flagurl ON country.entity_id = field_data_field_flagurl.entity_id;" > /tmp/output.txt

  while read -r country affiliation operators signed_mou saml edugain eduroam progress flag_url; do
    echo "$country $affiliation $operators $signed_mou $edugain $eduroam $progress $flag_url"
  done < /tmp/output.txt
exit