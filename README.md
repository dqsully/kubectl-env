# kubectl-env
Use the `kubectl`, `helm`, and `skaffold` CLIs across different clusters and
namespaces in different terminals. Rather than being forced to share a global
kubectl context, you can now set namespace and context settings with environment
variables or helper commands!

**Note: this only affects your shell.** If you run an executable that calls
`kubectl` under the hood then it won't be affected by kubectl-env.

## Installation
Clone down this repository somewhere, then in your `~/.bashrc` or `~/.zshrc` add
this:

```bash
source path/to/kubectl-env/init.sh
```

And that's

### Setup your prompt (optional but highly recommended)
kubectl-env comes prepackaged with a version of [kube-ps1] that's modified to
understand the environment variables that kubectl-env uses. You will have to
modify your shell prompt to use it though.

If your shell prompt ends with a `$` then you can add one of these lines to your
`~/.bashrc` or `~/.zshrc` respectively.

```bash
# Bash
PS1=$(echo "$PS1" | sed 's/\\\$/$(kube_ps1)\$/')

# Zsh
PROMPT=$(echo "$PROMPT" | sed 's/\\\$/$(kube_ps1)\$/')
```

If you have a different shell prompt, like if you are using a Zsh theme, then
you will need to write your own sed command. Just inject `'$(kube_ps1)'`
wherever you would like the kubernetes info to show up.

This version of kube-ps1 is hidden by default. See the
[commands section](#commands) for how to control kube-ps1's visibility.

### Pick which features are enabled
By default kubectl-env will enable the command injection and kube-ps1 system. If
the user has created the `k=kubectl` alias, then kubectl-env will automatically create
its own aliases as well. You can customize this with all the following arguments

* `"all"` - enable everything w/ aliases
* `"env"` - enable command injection w/o aliases
* `"env+alias"` - enable command injection w/ aliases
* `"ps1"` - enable kube-ps1 w/o aliases
* `"ps1+alias"` - enable kube-ps1 w/ aliases

Just append the arguments to your `source` line in your `.bashrc` or `.zshrc`:
```bash
# Enable everything
source path/to/kubectl-env/init.sh "all"

# Enable just the injection with aliases
source path/to/kubectl-env/init.sh "env+alias"

# Enable injection and ps1 without aliases
source path/to/kubeclt-env/init.sh "env" "ps1"
```

### Other settings
All of the [kube-ps1] settings are 100% functional.

## Commands
### Command injection
#### `kube-ctx` (alias `kctx`)
Sets the current terminal's kubectl context.

#### `kube-ns` (alias `kns`)
Sets the current terminal's kubernetes namespace.

### kube-ps1
#### `kubeon` (alias `kon`)
Enables the kube-ps1 display

#### `kubeoff` (alias `koff`)
Disables the kube-ps1 display

[kube-ps1]: https://github.com/jonmosco/kube-ps1
