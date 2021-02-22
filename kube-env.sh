#!/bin/bash

# Functions to inject ENVs into kubectl CLI
_kubectl_context() {
  if [[ -n "$KUBE_CONTEXT" ]]; then
    echo "--context" "$KUBE_CONTEXT"
  fi
}

_kubectl_namespace() {
  if [[ -n "$KUBE_NAMESPACE" ]]; then
    echo "--namespace" "$KUBE_NAMESPACE"
  fi
}

_helm_context() {
  if [[ -n "$KUBE_CONTEXT" ]]; then
    echo "--kube-context" "$KUBE_CONTEXT"
  fi
}

_helm_namespace() {
  if [[ -n "$KUBE_NAMESPACE" ]]; then
    echo "--namespace" "$KUBE_NAMESPACE"
  fi
}

# Override for kubectl to provide ENV context and namespace
KUBECTL_BINARY=$(which kubectl)
kubectl() {
  $KUBECTL_BINARY $(_kubectl_context) $(_kubectl_namespace) "$@"
}

# Override for helm to provide ENV context
HELM_BINARY=$(which helm)
helm() {
  $HELM_BINARY $(_helm_namespace) $(_helm_context) "$@"
}

# Override for skaffold to provide ENV context
SKAFFOLD_BINARY=$(which skaffold)
skaffold() {
    $SKAFFOLD_BINARY $(_helm_context) "$@"
}

# Functions to set kubectl ENVs
kube-ns() {
  if [[ "$1" == "" ]]; then
    if [[ "$KUBE_NAMESPACE" == "" ]]; then
      echo "No local namespace override active";
    else
      echo "Unset local namespace override";
    fi
  else
    echo "Set local namespace override to '$1'";
  fi

  KUBE_NAMESPACE=$1
}

kube-ctx() {
  if [[ "$1" == "" ]]; then
    if [[ "$KUBE_CONTEXT" == "" ]]; then
      echo "No local context override set";
    else
      echo "Unset local context override";
    fi
  else
    local matches=0

    for context in $($KUBECTL_BINARY config get-contexts -o name); do
      if [[ "$context" == "$1" ]]; then
        matches=1
        break
      fi
    done

    if [[ $matches == 0 ]]; then
      echo "'$1' is not a configured kubectl context"
      echo "(you can list your contexts with 'kubectl config get-contexts')"
      return 1
    fi

    echo "Set local context override to '$1'";
  fi

  KUBE_CONTEXT=$1
}

# completions for kubectl ENV cmds
__kube_env_get() {
  kubectl get -o template --template="{{ range .items }}{{ .metadata.name }} {{ end }}" "$1"
}
__kube_env_config() {
  kubectl config -o template --template="{{ range .$1 }}{{ .name }} {{ end }}" view
}
__kube_env_ns_zsh() {
  compadd $(__kube_env_get namespaces)
}
__kube_env_ctx_zsh() {
  compadd $(__kube_env_config contexts)
}
__kube_env_ns_bash() {
  COMPREPLY=($(__kube_env_get namespaces))
}
__kube_env_ctx_bash() {
  COMPREPLY=($(__kube_env_config contexts))
}

if [[ "${ZSH_VERSION-}" ]]; then
  compdef __kube_env_ns_zsh kube-ns
  compdef __kube_env_ctx_zsh kube-ctx
else
  complete -F __kube_env_ns_bash kube-ns
  complete -F __kube_env_ctx_bash kube-ctx

  # Completions for optional aliases
  if [[ $1 == "alias" ]]; then
    complete -F __kube_env_ns_bash kns
    complete -F __kube_env_ctx_bash kctx
  fi
fi

# Optional aliases
if [[ $1 == "alias" ]]; then
  alias kctx=kube-ctx
  alias kns=kube-ns
fi
