#!/bin/sh

if [ "x$1" = "x--remote" ]; then
  git_repo="$1 $2"
  shift 2
fi

pre_cmd_args=""
# FIXME: robust processing of selected pre gitlab command args.
for i in 1 2; do
  case $1 in
    -g|--gitlab|-c|--config-file)
      pre_cmd_args="$pre_cmd_args $1 $2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# last pipeline:
pipeid=$(git gitlab $git_repo project-pipeline list | head -n 1 | cut -d: -f2)
[ -n "$pipeid" ] || exit 0
git gitlab $git_repo $pre_cmd_args -o yaml -f id,status,web_url project-pipeline get --id $pipeid

git gitlab $git_repo $pre_cmd_args -o yaml -f id,name,status,web_url project-pipeline-job list --pipeline-id $pipeid

#projurl=$(echo $url | sed "s#:\($proj\)#/\\1#")
#projurl=$(echo $projurl | sed 's#git@#https://#')
#projurl=$(echo $projurl | sed -e 's#\.git$##')
#joburl="$projurl/-/jobs/"
#echo $joburl
