{ stdenv, fetchFromGitHub }:
let
sugar-candy = stdenv.mkDerivation {
  pname = "sddm-sugar-candy-theme";
  version = "1.2";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -aR $src/* $out
  '';
  src = fetchFromGitHub {
    owner = "Kangie";
    repo = "sddm-sugar-candy";
    rev = "a1fae5159c8f7e44f0d8de124b14bae583edb5b8";
    sha256 = "p2d7I0UBP63baW/q9MexYJQcqSmZ0L5rkwK3n66gmqM=";
  };
};
my_files = stdenv.mkDerivation {
  pname = "my_files";
  version = "";
  src = [ ../../../conf.d/sddm ../../../conf.d/wallpaper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    for file in $src; do
      cp -aR $file/* $out
    done
  '';
};
in
stdenv.mkDerivation {
  name = "mod-sugar-candy";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/sddm/themes/sugar-candy
    cp -aR ${sugar-candy}/* $out/share/sddm/themes/sugar-candy/
    rm $out/share/sddm/themes/sugar-candy/theme.conf
    cp -aR ${my_files}/sugar-candy.conf $out/share/sddm/themes/sugar-candy/theme.conf
    mkdir -p $out/share/sddm/themes/sugar-candy/my_wallpapers/
    cp -aR ${my_files}/hl2.png $out/share/sddm/themes/sugar-candy/my_wallpapers/
  '';
}
