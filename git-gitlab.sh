#!/bin/sh

select_remote () {
  remotes=$(git remote)
  if [ $(echo $remotes | wc -w) -gt 1 ]; then
    for r in $remotes; do
      [ $r != origin ] || remote=$r
      u=$(git remote get-url $r)
      echo "$r, url: $u"
    done
    [ -n "$remote" ] || remote=$r
    read -p "Please select a remote [$remote]: " read_remote
    for r in $remotes; do
      [ $r != "$read_remote" ] || remote=$read_remote
    done
  else
    remote=$remotes
  fi
}

instance_name() {
  host=$1
  grep -B 5 "^\s*url\s*=\s*http\(s\)*://$host" ~/.python-gitlab.cfg | grep "^\[" | tail -n 1 | sed -e 's#\[\(.\+\)\]#\1#'
}

if [ "x$1" = "x--git-remote" ]; then
  remote=$2
  shift 2
fi
[ -n "$remote" ] || remote=$(git remote)
if [ -z "$remote" ]; then
  echo "No remotes found in repository"
  exit 1
fi
if [ $(echo $remote | wc -w) -gt 1 ]; then
  echo "Multiple remotes found, specify a remote using --git-remote REMOTE"
  exit 1
fi

url=$(git remote get-url $remote)
host=$(echo $url | sed -e 's#^\(git\@\|[a-z]\+://\)\([^:/]\+\)[:/].*#\2#')
instance=$(instance_name $host)
if [ -z "$instance" ]; then
  echo "No instance found for $host in ~/python-gitlab.cfg"
  exit 1
fi

proj=$(echo $url | sed -e 's#.*:\(.*\)$#\1#')
proj=$(echo $proj | sed -e 's#\.git$##')
projid=$proj

gitlab -g $instance $* --project-id $projid
