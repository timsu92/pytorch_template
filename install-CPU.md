# CPU-only Installation Guide

This guide will help you set up the project in a CPU-only environment (without CUDA/GPU acceleration).

## Option 1: Using VSCode Devcontainer (Recommended)

### Step 1: Modify configuration files for CPU-only setup

Before proceeding, you'll need to modify three files to remove GPU requirements:

1. First, modify `docker-compose.yml` and `.devcontainer/docker-compose-dev.yml`:
   - Open the file and remove the entire `deploy` section which requests GPU resources:

   ```yaml
   # Remove this section
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             capabilities: [gpu]
   ```

2. Next, modify the `Dockerfile`:
   - Open the file and change the base image from NVIDIA CUDA to a regular Ubuntu image
   - Replace:
     ```dockerfile
     ARG BASE_IMAGE=nvidia/cuda:12.2.2-base-ubuntu22.04
     ```
   - With:
     ```dockerfile
     ARG BASE_IMAGE=ubuntu:22.04
     ```

### Step 2: Install required software

1. Install [Docker](https://docs.docker.com/engine/install/)
2. Install [Visual Studio Code](https://code.visualstudio.com/)
3. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Step 3: Open project in devcontainer

1. When VSCode opens the project, you should see a notification to reopen in container. If not:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Reopen in Container" and select the option

2. Wait for the container to build (this may take several minutes on first run)

3. Once complete, you'll be working within the container with all dependencies installed

### Step 4: Verify installation

In the VSCode terminal (inside the container):

```bash
python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
```

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

### Step 2: Modify requirements for CPU-only (if needed)

Check if the requirements specify CUDA-specific packages. If they do, you may need to modify them or install with a CPU-only flag.

### Step 3: Install dependencies

```bash
# Install dependencies from pyproject.toml and uv.lock
uv sync --frozen
```

### Step 4: Install additional system packages for OpenCV (if needed)

If you plan to use OpenCV:

```bash
# Basic OpenCV requirements
sudo apt update && sudo apt install -y libgl1 libglib2.0-0

# Additional packages for cv2.imshow() functionality
sudo apt install -y libpng16-16 libsm6 libxaw7 libxcursor1 libxft2 libxkbfile1 libxmu6 libxmuu1 libxrender1 libxt6
```

### Step 5: Verify installation

```bash
python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
```

## Troubleshooting

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
