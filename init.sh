#!/bin/bash

dir=$(dirname $_)

if [[ -z $1 ]]; then
  # Default "smart" install

  if alias | grep -E "^(alias )?kgp=" >/dev/null; then
    # Kubectl aliases installed
    source $dir/kube-env.sh "alias"
    source $dir/kube-ps1.sh "alias"
  else
    # Kubectl aliases not installed
    source $dir/kube-env.sh
    source $dir/kube-ps1.sh
  fi

else
  for arg in $@; do
    case $arg in
      "all")
        source $dir/kube-ps1.sh "alias"
        source $dir/kube-env.sh "alias"
        ;;

      "env")
        source $dir/kube-env.sh
        ;;

      "env+alias")
        source $dir/kube-env.sh "alias"
        ;;

      "ps1")
        source $dir/kube-ps1.sh
        ;;

      "ps1+alias")
        source $dir/kube-ps1.sh "alias"
        ;;
    esac
  done
fi

