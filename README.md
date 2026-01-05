# PBDE: Final Assigment

This repository contains the code to reproduce the results presented in the submission of the Final Assigment of the PBDE course (MESIO Fall 2025).

## Installation

In order to build the project we recommend to have a `Nix` installation in your machine and reproduce the fully-fledged development environment using `devenv`: in this case just run `devenv shell` and the resulting shell will build the Python `.venv` using `uv`. The actual `.venv` environment should be found at `.devenv/state/venv`.

Otherwise, if you have a Python installation (`>= 3.12`) in your machine, you can build the project using the `pyproject.toml` file.