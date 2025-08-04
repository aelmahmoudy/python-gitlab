#!/bin/sh

DFLT_PYGLAB_CONF=~/.python-gitlab.cfg

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
  pyglab_conf=$2
  grep -B 5 "^\s*url\s*=\s*http\(s\)*://$host" $pyglab_conf | grep "^\[" | tail -n 1 | sed -e 's#\[\(.\+\)\]#\1#'
}

remote=$(git config gitlab.remote)
[ -n "$remote" ] || remote=$(git remote)
if [ "x$1" = "x--remote" ]; then
  remote=$2
  shift 2
fi

pyglab_conf=$DFLT_PYGLAB_CONF
pre_cmd_args=""
while echo $1 | grep -q "^-" ; do
  case $1 in
    -g|--gitlab|-o|--output|-f|--fields)
      pre_cmd_args="$pre_cmd_args $1 $2"
      shift 2
      ;;
    -c|--config-file)
      pyglab_conf=$2
      pre_cmd_args="$pre_cmd_args $1 $2"
      shift 2
      ;;
    *)
      pre_cmd_args="$pre_cmd_args $1"
      shift 1
      ;;
  esac
done
if [ -z "$remote" ]; then
  echo "No remotes found in repository"
  exit 1
fi
if [ $(echo $remote | wc -w) -gt 1 ]; then
  cat <<EOF
Multiple remotes found, specify a remote using '--remote REMOTE' argument
Alternatively, you can configure your git repository using the command:
git config --local gitlab.remote REMOTE"
EOF
  exit 1
fi

url=$(git remote get-url $remote)
host=$(echo $url | sed -e 's#^\(git\@\|[a-z]\+://\)\([^:/]\+\)[:/].*#\2#')
instance=$(instance_name $host $pyglab_conf)
if [ -z "$instance" ]; then
  echo "No instance found for $host in $pyglab_conf"
  exit 1
fi

proj=$(echo $url | sed -e 's#.*:\(.*\)$#\1#')
proj=$(echo $proj | sed -e 's#\.git$##')
projid=$proj

gitlab -g $instance $pre_cmd_args $* --project-id $projid
