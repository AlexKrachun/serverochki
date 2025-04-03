# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Randy Eckenrode
# Copyright (c) 2025 WeetHet

{ lib }:

let
  inherit (builtins) readDir;

  inherit (lib)
    attrNames
    filter
    filterAttrs
    pathExists
    ;
  inherit (lib.trivial) pipe;

  enumerateModules =
    {
      prefix ? "",
      basePath,
    }:
    let
      childPaths = path: attrNames (filterAttrs (_: type: type == "directory") (readDir path));
      mkPath = dir: "${basePath}/${dir}/${prefix}module.nix";
    in
    pipe basePath [
      childPaths
      (map mkPath)
      (filter pathExists)
    ];

  allModules = enumerateModules { basePath = ../by-name; };
in
{
  darwin =
    allModules
    ++ enumerateModules {
      prefix = "darwin-";
      basePath = ../by-name;
    };
  nixos =
    allModules
    ++ enumerateModules {
      prefix = "nixos-";
      basePath = ../by-name;
    };
  home = enumerateModules {
    prefix = "hm-";
    basePath = ../by-name;
  };
}
