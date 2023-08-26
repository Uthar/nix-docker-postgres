{ pkgs, lib, stdenv, pkgsMusl, dockerTools, buildEnv, ... }:

let
  mkJdk = { jdk, modules ? [ "java.base" ] }:
    stdenv.mkDerivation {
      inherit (jdk) pname version;
      buildInputs = [ jdk ];
      dontUnpack = true;
      stripDebugFlags = [ "--strip-unneeded" ];
      buildPhase = ''
        jlink \
          --module-path ${jdk}/lib/openjdk/jmods \
          --add-modules ALL-MODULE-PATH \
          --strip-debug \
          --no-man-pages \
          --no-header-files \
          --compress=1 \
          --output $out
      '';   
      dontInstall = true;    
    };
  jdk = mkJdk {
    jdk = pkgs.jdk17_headless;
    modules = [
      "java.base"
    ];
  };
  # jdk = pkgs.jre_minimal.override {
  #   jdk = pkgs.jdk20_headless;
  #   modules = [
  #     "java.base"
  #     # "java.sql"
  #   ];
  # };
in dockerTools.buildImage {
  name = "hello";
  tag = "latest";
  created = "now";
  
  copyToRoot = buildEnv {
    name = "env";
    paths = [
      # pkgs.busybox
      # pkgs.jdk20_headless
      # jdk
      # (pkgs.runCommand "var" {} "mkdir -p $out/var")
      dockerTools.fakeNss
      pkgs.bash
      pkgs.coreutils
    ];
  };

  config = {
    # Cmd = [ "hello" ];
    Cmd = [ "${pkgs.nginx}/bin/nginx" ];
  };
}
