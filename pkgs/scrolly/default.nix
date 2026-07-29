{buildGoModule}:
buildGoModule {
  pname = "scrolly";
  version = "0.1.0";
  src = ./.;
  vendorHash = null;
  # Scrolling now-playing text for waybar; talks to playerctl at runtime
  meta.mainProgram = "scrolly";
}
