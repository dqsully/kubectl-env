#!/bin/bash

if [[ "$1" != "--no-ps1" ]]; then
  # Enable custom kube-ps1 script
  source $(dirname $0)/kube-ps1.sh
fi

# Settings for kube-ps1
KUBE_PS1_BINARY=kubectl
KUBE_PS1_SEPARATOR=
KUBE_PS1_FIX_COLOR=blue

# kube-ps1 theme #1
# KUBE_PS1_NS_COLOR=green
# KUBE_PS1_CTX_COLOR=yellow

# kube-ps1 theme #2
KUBE_PS1_NS_COLOR=cyan
KUBE_PS1_CTX_COLOR=magenta

# Aliases for kube-ps1
alias kon=kubeon
alias koff=kubeoff


# Functions to inject ENVs into kubectl CLI
_kubectl_context() {
  if [[ -n "$KUBE_CONTEXT" ]]; then
    echo "--context" "$KUBE_CONTEXT"
  fi
}

_kubectl_namespace() {
  if [[ -n "$KUBE_NAMESPACE" ]]; then
    echo - "-n" "$KUBE_NAMESPACE"
  fi
}

_helm_context() {
  if [[ -n "$KUBE_CONTEXT" ]]; then
    echo "--kube-context" "$KUBE_CONTEXT"
  fi
}

_helm_namespace() {
  if [[ -n "$KUBE_NAMESPACE" ]]; then
    echo - "--namespace" "$KUBE_NAMESPACE"
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
  KUBE_NAMESPACE=$1
}

kube-ctx() {
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

if [[ -s "$ZSH" ]]; then
  compdef __kube_env_ns_zsh kube-ns
  compdef __kube_env_ctx_zsh kube-ctx
else
  complete -F __kube_env_ns_bash kube-ns
  complete -F __kube_env_ctx_bash kube-ctx
fi
