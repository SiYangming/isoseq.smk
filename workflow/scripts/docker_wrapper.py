#!/usr/bin/env python3
"""Execution-mode helpers for Iso-Seq Snakemake wrappers (native/conda/docker/apptainer)."""

__author__ = "Yangming Si"
__copyright__ = "Copyright 2026, Yangming Si"
__email__ = "siyangming1991@163.com"
__license__ = "MIT"

VALID_MODES = ("native", "conda", "docker", "apptainer")


def build_docker_command(image, volumes, workdir, cmd, platform="linux/amd64"):
    """Return argv for docker run (used by unit tests and optional callers)."""
    argv = [
        "docker",
        "run",
        "--rm",
        "--platform",
        platform,
        "-u",
        "$(id -u):$(id -g)",
        "-w",
        workdir,
    ]
    for vol in volumes:
        argv.extend(["-v", vol])
    argv.append(image)
    argv.extend(list(cmd))
    return argv


def build_apptainer_command(image, bind, workdir, cmd):
    """Return argv for apptainer exec."""
    argv = [
        "apptainer",
        "exec",
        "--bind",
        bind,
        "--pwd",
        workdir,
        image,
    ]
    argv.extend(list(cmd))
    return argv


def docker_run(exec_mode, platform="linux/amd64"):
    if exec_mode == "docker":
        return (
            f"docker run --rm --platform {platform} "
            f"-v $(pwd):$(pwd) -u $(id -u):$(id -g) -w $(pwd) "
        )
    if exec_mode == "apptainer":
        return "apptainer exec --bind $(pwd):$(pwd) --pwd $(pwd) "
    return ""


def _tool_cfg(config, tool_name):
    cfg = config.get(tool_name)
    if not isinstance(cfg, dict):
        raise ValueError(f"Missing tool config section: {tool_name}")
    return cfg


def docker_wrapper_binary(config, tool_name, bin_key, default_bin):
    exec_mode = config.get("exec_mode", "conda")
    if exec_mode not in VALID_MODES:
        raise ValueError(
            f"Invalid exec_mode={exec_mode!r}; expected one of {VALID_MODES}"
        )
    tool = _tool_cfg(config, tool_name)

    if exec_mode == "docker":
        docker_image = tool.get("docker_image") or ""
        if not docker_image:
            raise ValueError(
                f"Missing docker_image under {tool_name} when exec_mode is docker"
            )
        return f"{docker_run(exec_mode)}{docker_image} ", default_bin

    if exec_mode == "apptainer":
        image = tool.get("apptainer_image") or ""
        if not image:
            docker_image = tool.get("docker_image") or ""
            if docker_image:
                image = (
                    docker_image
                    if docker_image.startswith(("docker://", "oras://", "library://"))
                    else f"docker://{docker_image}"
                )
        if not image:
            raise ValueError(
                f"Missing apptainer_image/docker_image under {tool_name} "
                "when exec_mode is apptainer"
            )
        return f"{docker_run(exec_mode)}{image} ", default_bin

    if exec_mode == "native":
        tool_bin = tool.get(bin_key) or ""
        if not tool_bin:
            raise ValueError(f"Missing {bin_key} in {tool_name} when exec_mode is native")
        return "", tool_bin

    return "", default_bin
