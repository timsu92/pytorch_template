# Installation Guide

This document provides guidance on how to install and set up this project. There are two main approaches to installation, and each approach can be implemented for either CUDA (GPU) or CPU-only environments.

## Installation Options

### Based on your hardware:

- **CUDA/GPU Environment**: If you have an NVIDIA GPU and want to utilize it for accelerated computing, follow the [CUDA Installation Guide](install-CUDA.md).
- **CPU-only Environment**: If you don't have an NVIDIA GPU or prefer not to use it, follow the [CPU-only Installation Guide](install-CPU.md).

### Based on your preferred method:

Both guides above will provide instructions for two installation methods:
- **VSCode Devcontainer**: A convenient approach using Visual Studio Code's Development Containers feature
- **Manual Installation with uv**: Step-by-step instructions for manual installation using the uv Python package manager

## Prerequisites

- For CUDA setup: An NVIDIA GPU with compatible drivers installed
- For Devcontainer setup: Docker and VSCode with the Dev Containers extension
- For Manual setup: Python >=3.10 and uv package manager

Choose the installation guide that best fits your hardware configuration and preferences.
