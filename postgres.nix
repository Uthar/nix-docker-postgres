{ pkgs, lib, stdenv, pkgsMusl, dockerTools, buildEnv, ... }:

let
  
  postgres = pkgs.postgresql_15;
  
in dockerTools.buildImage {
  name = "kaspi/postgres";
  tag = postgres.version;
  created = "now";
  
  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      (dockerTools.fakeNss.override {
        extraPasswdLines = [
          "postgres:x:1000:1000:postgres:/var/empty:/bin/sh"
        ];
        extraGroupLines = [
          "postgres:x:1000:"
        ];
      })
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.vim
      pkgs.mg
      postgres
    ];
  };

  runAsRoot = ''
    #!${pkgs.bash}/bin/bash
    mkdir /data
    chown postgres:postgres /data
  '';

  config = {
    Cmd = [ "postgres" ];
    Env = [ "PGDATA=/data" ];
    User = "postgres";
    Group = "postgres";
  };
}
