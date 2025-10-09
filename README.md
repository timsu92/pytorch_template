# Tempelate for a Python PyTorch uv Project

This is a template for a Python PyTorch uv project. It is configured to use cuda 12.2.2, python >=3.10, ubuntu 22.04 and PyTorch 2.5.1. Coding with devcontainers is supported.

## Features

- Python >=3.10
- uv latest
- CUDA 12.2.2
- Ubuntu 22.04
- Git, vim, wget, curl
- Timezone in Asia/Taipei
- Support for OpenCV windows (xcb)

## Changes before using

Before using this template, you may want to change the project path in these files:
- [docker-compose.yml line 4](./docker-compose.yml#L4)
- [docker-compose.yml line 17](./docker-compose.yml#L17)
- [.devcontainer/docker-compose-dev.yml line 4](./.devcontainer/docker-compose-dev.yml#L4)
- [.devcontainer/docker-compose-dev.yml line 17](./.devcontainer/docker-compose-dev.yml#L17)
- [.devcontainer/docker-compose-dev.yml line 20](./.devcontainer/docker-compose-dev.yml#L20)
- [.devcontainer/devcontainer.json line 3](./.devcontainer/devcontainer.json#L3)
- [.devcontainer/devcontainer.json line 10](./.devcontainer/devcontainer.json#L10)

...and you may want to change the project name:
- [pyproject.toml line 2](./pyproject.toml#L2)

...and you may want to change the Python version:
- [pyproject.toml line 9](./pyproject.toml#L9)

...and you may want to change uv's version:
- [.github/workflows/python-locks.yml line 14](./.github/workflows/python-locks.yml#L14)

## Usage

### Using VSCode for development

1. Install [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
2. Open this project in VSCode.
3. Click the `Reopen in Container` button.

### Build and run for production

Just run:

```sh
docker compose up --build
```

