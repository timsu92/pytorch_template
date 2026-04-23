# Template for a Python PyTorch uv Project

This is a template for a Python PyTorch uv project. It is configured to use cuda 12.8.1, python >=3.10, ubuntu 24.04 and PyTorch 2.9.0. Coding with devcontainers is supported.

## Features

- Python >=3.10
- uv latest
- CUDA 12.8.1
- Ubuntu 24.04
- Git, vim, wget, curl
- Timezone in Asia/Taipei
- Support for OpenCV windows (xcb)

## Changes before using

Before using this template, you may want to change the project name:
- [.devcontainer/devcontainer.json line 3](./.devcontainer/devcontainer.json#L3)
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

By default, devcontainer uses the upstream prebuilt image:

- `ghcr.io/timsu92/pytorch_template:main`

It still keeps the compose-based workflow (volumes, GPU settings, environment variables), but avoids rebuilding the dev image in every consumer project.

If you want to test Dockerfile changes locally (maintainer mode), temporarily switch [.devcontainer/devcontainer.json](./.devcontainer/devcontainer.json) to:

```jsonc
"dockerComposeFile": ["docker-compose-dev.yml", "docker-compose-dev.build.yml"]
```

Then run `Rebuild Container`.

### Auto publish dev image

GitHub Actions workflow [.github/workflows/publish-dev-image.yml](./.github/workflows/publish-dev-image.yml) builds the `dev` stage and publishes to GHCR when relevant files change:

- `.devcontainer/**`
- `.dockerignore`
- `docker-compose.yml`
- `Dockerfile`
- `.github/workflows/publish-dev-image.yml`

It also runs on:

- manual trigger (`workflow_dispatch`)
- weekly schedule: Sunday 03:00 Asia/Taipei

Fork repositories do not push images by default, and will consume the upstream image unless explicitly changed.

### Build and run for production

Just run:

```sh
docker compose up --build
```

