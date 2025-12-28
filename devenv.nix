{
  pkgs,
  lib,
  config,
  ...
}:
{
  languages.python = {
    enable = true;
    version = "3.12.3";
    uv.enable = true;
    uv.sync.enable = true;
    uv.sync.arguments = ["--python-preference" "managed"];
  };

  languages.typst.enable = true;

  enterShell = ''
    VENV_PATH=$(uv run --quiet python -c "import sys; print(sys.prefix)")
    source "$VENV_PATH/bin/activate"
  '';
}