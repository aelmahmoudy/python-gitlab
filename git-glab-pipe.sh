#!/bin/sh

# TODO:
#   check args for cfg file
if [ "x$1" = "x--remote" ]; then
  git_repo="$1 $2"
  shift 2
fi
# last pipeline:
pipeid=$(git gitlab $git_repo project-pipeline list | head -n 1 | cut -d: -f2)
git gitlab $git_repo -o yaml -f id,status,web_url project-pipeline get --id $pipeid

git gitlab $git_repo -o yaml -f id,name,status,web_url project-pipeline-job list --pipeline-id $pipeid

#projurl=$(echo $url | sed "s#:\($proj\)#/\\1#")
#projurl=$(echo $projurl | sed 's#git@#https://#')
#projurl=$(echo $projurl | sed -e 's#\.git$##')
#joburl="$projurl/-/jobs/"
#echo $joburl
