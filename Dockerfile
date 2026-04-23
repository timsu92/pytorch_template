# syntax=docker/dockerfile:1.17-labs
ARG BASE_IMAGE=nvidia/cuda:12.8.1-base-ubuntu24.04

FROM $BASE_IMAGE AS python-base
ARG NONROOT_USERNAME=nonroot

# python
ENV PYTHONUNBUFFERED=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

################################################################################

FROM python-base AS prod-prepare
ARG DEBIAN_FRONTEND=noninteractive
ARG NONROOT_USERNAME

    # Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy \
    # compile python into .pyc files
    UV_COMPILE_BYTECODE=1 \
    # uv
    UV_CACHE_DIR="/home/${NONROOT_USERNAME}/.cache/uv"

# # credential for private repos
    # # install GitHub CLI
# ADD --chown=root:root --chmod=644 https://cli.github.com/packages/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    # --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # mkdir -p -m 755 /etc/apt/sources.list.d \
        # && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
        # && apt update \
        # && apt install gh -y

RUN useradd -ms /bin/bash ${NONROOT_USERNAME} --user-group
USER ${NONROOT_USERNAME}

# # login to GitHub CLI
# RUN --mount=type=secret,id=GIT_AUTH_TOKEN,required=true,uid=1000,gid=1000 \
    # gh auth login --with-token < /run/secrets/GIT_AUTH_TOKEN
# RUN gh auth setup-git

ARG PROJECT_PATH
# python
ENV VENV_PATH="${PROJECT_PATH}/.venv"
# prepend venv to path
ENV PATH="$VENV_PATH/bin:$PATH"
WORKDIR ${PROJECT_PATH}

# # install runtime deps - without project itself
    # # uv download cache
# RUN --mount=type=cache,dst=${UV_CACHE_DIR},uid=1000,gid=1000 \
    # # uv itself
    # --mount=from=ghcr.io/astral-sh/uv:latest,source=/uv,target=/bin/uv \
    # # Project files
    # --mount=type=bind,source=pyproject.toml,target=${PROJECT_PATH}/pyproject.toml \
    # --mount=type=bind,source=uv.lock,target=${PROJECT_PATH}/uv.lock \
    # # If there are projects need ssh access
    # # --mount=type=ssh \
    # uv sync --frozen --no-install-project --no-install-workspace --no-dev

# install runtime deps - with project itself
    # uv download cache
RUN --mount=type=cache,dst=${UV_CACHE_DIR},uid=1000,gid=1000 \
    # uv itself
    --mount=from=ghcr.io/astral-sh/uv:latest,source=/uv,target=/bin/uv \
    # Project files
    --mount=type=bind,source=pyproject.toml,target=${PROJECT_PATH}/pyproject.toml \
    --mount=type=bind,source=uv.lock,target=${PROJECT_PATH}/uv.lock \
    uv sync --locked --no-dev

################################################################################

FROM python-base AS prod
ARG DEBIAN_FRONTEND=noninteractive
ARG NONROOT_USERNAME

ARG TZ
ENV TZ=${TZ}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # timezone
        tzdata
# set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

RUN useradd -ms /bin/bash ${NONROOT_USERNAME} --user-group
USER ${NONROOT_USERNAME}
WORKDIR ${PROJECT_PATH}

COPY --chown=${NONROOT_USERNAME}:${NONROOT_USERNAME} --from=prod-prepare /home/${NONROOT_USERNAME}/.local/share/uv/python /home/${NONROOT_USERNAME}/.local/share/uv/python
COPY --chown=${NONROOT_USERNAME}:${NONROOT_USERNAME} --from=prod-prepare ${VENV_PATH} ${VENV_PATH}

COPY --exclude=.devcontainer/ --chown=${NONROOT_USERNAME}:${NONROOT_USERNAME} . .

################################################################################

FROM python-base AS dev
ARG DEBIAN_FRONTEND=noninteractive
    # Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy \
    # uv
    UV_CACHE_DIR="/root/.cache/uv"
ARG TZ
ENV TZ=${TZ}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # timezone
        tzdata \
        # useful tools
        git vim wget curl ca-certificates less
# set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for dev dep opencv
        libgl1 libglib2.0-0 \
        # deps for dev dep opencv imshow
        libsm6

# Initialize user environment
ARG ENV_SETUP_REPO=https://github.com/timsu92/env_setup.git
ARG ENV_SETUP_REF=main
RUN --mount=type=tmpfs,dst=/tmp/dotfiles \
    git -C /tmp/dotfiles init \
    && git -C /tmp/dotfiles remote add origin ${ENV_SETUP_REPO} \
    && git -C /tmp/dotfiles fetch --depth=1 origin ${ENV_SETUP_REF} \
    && git -C /tmp/dotfiles checkout --detach FETCH_HEAD \
    && /tmp/dotfiles/bin/setup-devcontainer

ARG PROJECT_PATH
WORKDIR ${PROJECT_PATH}

# python
ENV VENV_PATH="${PROJECT_PATH}/.venv"
# prepend venv to path
ENV PATH="$VENV_PATH/bin:$PATH"

CMD ["/bin/sh", "-c", "echo \"Container started\"; trap \"echo Container stopped; exit 0\" 15; exec \"$@\"; while sleep 1 & wait $!; do :; done"]
