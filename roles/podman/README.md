# geraldyaya.ecstasy podman Role

Install and configure Podman, a tool for managing OCI containers and pods.

## Role Variables

| Variable             | Description                                     | Default   |
| -------------------- | ----------------------------------------------- | --------- |
| `podman_auto_update` | Whether to enable the auto-update service/timer | `true`    |
| `podman_state`       | Whether the Podman package should be installed  | `present` |

## Dependencies

- geraldyaya.ecstasy.systemd

## Example Playbook

```yaml
- name: Install and configure Podman
  hosts: servers
  roles:
    - role: geraldyaya.ecstasy.podman
      vars:
        podman_auto_update: true # can be omitted, defaults to true
```

```yaml
- name: Uninstall Podman
  hosts: servers
  roles:
    - role: geraldyaya.ecstasy.podman
      vars:
        podman_state: absent
```

## Role Idempotency

True

## Role Atomicity

False

## Roll-back capabilities

None

## License

GPL-3.0-only
