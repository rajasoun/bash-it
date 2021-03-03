# bash-it

Collection of scripts that simplifies 

- Build and Release docker images based upon git tags leveraging Generic Makefile [Thanks to Mark van Holsteijn](https://github.com/mvanholsteijn/docker-makefile)
- Secrets Management using [AWS secrets Manager](https://aws.amazon.com/secrets-manager/) built on top of [aws-vault](https://github.com/99designs/aws-vault) and [secretscli](https://github.com/tedivm/secretcli)


Reference Implementation

- Use following Code Snippet in leveraging the [docker framework](reference-implementation/docker-ri.bash) for 

```shell
# shellcheck source=bash-it/scripts/docker.bash
source "$SCRIPT_DIR/assist/docker.bash"
```

- Use following Code Snippet in leveraging the [secrets management](reference-implementation/secrets-manager-ri.bash) framework

```shell
# shellcheck source=bash-it/scripts/docker.bash
source "$SCRIPT_DIR/assist/docker.bash"
```
 

