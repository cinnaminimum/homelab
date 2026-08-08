# Development

The development (and CI) environment is managed with
[mise](https://mise.jdx.dev/).

## Testing

Use `mise run test` to run _most_ (sanity and units) tests. See below for
information about running [integration tests](#integration-tests).

### Integration tests

**Integration tests are destructive (do not run them in a development or
production environment).**

Integration tests are not included in the regular testing workflow due to their
requirements (namely systemd, which does not typically run in OCI containers).
The recommended approach is to run them in a dedicated test environment (e.g.
throwaway debian VM) with `mise run test:ansible:integration -- --target
ssh:user@testhost,python=3.xx`. Note that specifying the python interpreter
version of the host is required.

## Adding new content

New content can be scaffolded with `ansible-creator`.

### Adding a new role

A new role can be scaffolded by running:

```bash
mise exec -- ansible-creator add resource role role_name
```
