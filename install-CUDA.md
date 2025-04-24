# CUDA Installation Guide

This guide will help you set up the project in an environment with CUDA support for GPU acceleration.

## Prerequisites

### Check your CUDA version

This project is configured for CUDA 12.2.2. To check your installed CUDA version:

```sh
nvidia-smi
```

If your CUDA version is different, you'll need to modify the base image in the Dockerfile:

1. Open `Dockerfile` in the project root
2. Find the line starting with `ARG BASE_IMAGE=`
3. Update it to match your CUDA version

## Option 1: Using VSCode Devcontainer (Recommended)

This is the simplest approach as it automatically sets up the development environment.

### Step 1: Install required software

1. Install [Docker](https://docs.docker.com/engine/install/)
2. Install [Visual Studio Code](https://code.visualstudio.com/)
3. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Step 2: Open project in devcontainer

1. When VSCode opens the project, you should see a notification to reopen in container. If not:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Reopen in Container" and select the option

2. Wait for the container to build (this may take several minutes on first run)

3. Once complete, you'll be working within the container with all dependencies installed

### Step 3: Verify installation

In the VSCode terminal (inside the container):

```bash
python -c "import torch; print(torch.cuda.is_available())"
```

This should return `True` if CUDA is properly configured.

## Option 2: Manual Installation with uv

If you prefer to work without devcontainers, you can install the project dependencies manually with uv.

### Step 1: Install uv

```bash
# On macOS and Linux.
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```bash
# On Windows.
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Step 2: Install dependencies

```bash
# Install dependencies from pyproject.toml and uv.lock
uv sync --frozen
```

### Step 3: Install additional system packages for OpenCV (if needed)

If you plan to use OpenCV:

```bash
# Basic OpenCV requirements
sudo apt update && sudo apt install -y libgl1 libglib2.0-0

# Additional packages for cv2.imshow() functionality
sudo apt install -y libpng16-16 libsm6 libxaw7 libxcursor1 libxft2 libxkbfile1 libxmu6 libxmuu1 libxrender1 libxt6
```

### Step 4: Verify installation

```bash
python -c "import torch; print(torch.cuda.is_available())"
```

## Troubleshooting

### CUDA not detected

1. Verify your NVIDIA drivers are installed and working:
   ```bash
   nvidia-smi
   ```

2. Check that your CUDA version matches the version in the Dockerfile

3. If using manual installation, ensure PyTorch was installed with CUDA support:
   ```bash
   python -c "import torch; print(torch.__version__); print(torch.version.cuda)"
   ```

### Python version issues

Ensure you're using Python >=3.10 as specified in the project requirements:

```bash
python --version
```

If needed, consider using uv's Python environment management to install and use the correct Python version:

```bash
# Create a new virtual environment with Python 3.10
uv venv -p 3.10

# Verify Python's version
uv run python --version
```

### Other issues

For other issues, please check the project's GitHub issues or create a new issue.
