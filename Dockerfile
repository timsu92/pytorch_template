ARG BASE_IMAGE=nvidia/cuda:12.2.2-base-ubuntu22.04

FROM $BASE_IMAGE AS python-base
ARG PROJECT_PATH
ARG NONROOT_USERNAME=nonroot

# python
ENV PYTHONUNBUFFERED=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    VENV_PATH="${PROJECT_PATH}/.venv"

# prepend venv to path
ENV PATH="$VENV_PATH/bin:$PATH"

################################################################################

FROM python-base AS prod
ARG DEBIAN_FRONTEND=noninteractive
ARG NONROOT_USERNAME

    # Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy \
    # compile python into .pyc files
    UV_COMPILE_BYTECODE=1 \
    # uv
    UV_CACHE_DIR="/home/${NONROOT_USERNAME}/.cache/uv"

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

# install runtime deps - without project itself
    # uv download cache
RUN --mount=type=cache,dst=${UV_CACHE_DIR},uid=1000,gid=1000 \
    # uv itself
    --mount=from=ghcr.io/astral-sh/uv:latest,source=/uv,target=/bin/uv \
    # Project files
    --mount=type=bind,source=pyproject.toml,target=${PROJECT_PATH}/pyproject.toml \
    --mount=type=bind,source=uv.lock,target=${PROJECT_PATH}/uv.lock \
    # Git auth for some private repos
    # --mount=type=secret,id=GIT_AUTH_TOKEN,env=GIT_AUTH_TOKEN \
    # poetry config repositories.REPO_NAME https://github.com/SOME_ORG/SOME_REPO.git && \
    # poetry config http-basic.REPO_NAME username ${GIT_AUTH_TOKEN} && \
    uv sync --frozen --no-install-project --no-install-workspace --no-dev
    # poetry config --unset http-basic.REPO_NAME

COPY --chown=${NONROOT_USERNAME}:${NONROOT_USERNAME} . .

# install runtime deps - with project itself
    # uv download cache
RUN --mount=type=cache,dst=${UV_CACHE_DIR},uid=1000,gid=1000 \
    # uv itself
    --mount=from=ghcr.io/astral-sh/uv:latest,source=/uv,target=/bin/uv \
    uv sync --frozen --no-dev

################################################################################

FROM python-base AS dev
ARG DEBIAN_FRONTEND=noninteractive
    # uv
ENV UV_CACHE_DIR="/root/.cache/uv"
ARG TZ
ENV TZ=${TZ}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # timezone
        tzdata \
        # deps for building python deps
        build-essential \
        # useful tools
        git vim wget curl
# set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR ${PROJECT_PATH}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for dev dep opencv
        libgl1 libglib2.0-0 \
        # deps for dev dep opencv imshow
        libpng16-16 libsm6 libxaw7 libxcursor1 libxft2 libxkbfile1 libxmu6 libxmuu1 libxrender1 libxt6

CMD ["/bin/sh", "-c", "echo \"Container started\"; trap \"echo Container stopped; exit 0\" 15; exec \"$@\"; while sleep 1 & wait $!; do :; done"]
