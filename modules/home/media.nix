{
  lib,
  pkgs,
  ...
}: {
  home.packages =
    [pkgs.ffmpeg-full]
    ++ lib.optionals pkgs.stdenv.isDarwin [pkgs.moltenvk];

  programs = {
    aria2 = {
      enable = true;
      settings = {
        auto-save-interval = 10;
        bt-detach-seed-only = true;
        bt-enable-lpd = true;
        bt-load-saved-metadata = true;
        bt-max-peers = 255;
        bt-prioritize-piece = "head";
        bt-remove-unselected-file = true;
        bt-save-metadata = true;
        bt-seed-unverified = true;
        check-certificate = false;
        check-integrity = true;
        content-disposition-default-utf8 = true;
        continue = true;
        dht-entry-point = "dht.transmissionbt.com:6881";
        dht-entry-point6 = "dht.transmissionbt.com:6881";
        disk-cache = "1024M";
        enable-dht6 = true;
        file-allocation = "falloc";
        max-concurrent-downloads = 16;
        max-connection-per-server = 16;
        max-file-not-found = 10;
        max-overall-upload-limit = "5M";
        max-tries = 10;
        max-upload-limit = "1M";
        min-split-size = "8M";
        peer-agent = "Transmission/2.94";
        peer-id-prefix = "TR2940-";
        retry-wait = 30;
        save-session-interval = 10;
        split = 64;
      };
    };
    mpv = {
      enable = true;
      package = pkgs.mpv-unwrapped.wrapper {
        mpv = pkgs.mpv-unwrapped.override {
          ffmpeg = pkgs.ffmpeg-full;
        };
      };
      bindings = {
        WHEEL_UP = "add volume 2";
        WHEEL_DOWN = "add volume -2";
        AXIS_UP = "add volume 2";
        AXIS_DOWN = "add volume -2";
        "Shift+RIGHT" = "frame-step";
        "Shift+LEFT" = "frame-back-step";
        a = "cycle audio";
        s = "cycle sub";
        "1" = "set window-scale 0.5;set geometry 99%:99%";
        "2" = "set window-scale 1;set geometry 99%:99%";
        "3" = "set window-scale 1.5;set geometry 99%:99%";
        "4" = "set window-scale 2;set geometry 99%:99%";
      };
      config =
        {
          # Default profile
          vo = "gpu-next,gpu,";
          gpu-api = "vulkan,opengl,";
          # see: https://github.com/mpv-player/mpv/issues/12946
          # gpu-context = lib.mkIf pkgs.stdenv.isLinux "x11vk";
          # gpu-context = lib.mkIf pkgs.stdenv.isLinux (
          #   if config.wayland.windowManager.hyprland.enable
          #   then "waylandvk"
          #   else "x11vk"
          # );
          hwdec = "auto";
          vulkan-async-compute = true;
          vulkan-async-transfer = true;
          vd-lavc-dr = true;
          hr-seek-framedrop = true;
          reset-on-next-file = "audio-delay,mute,pause,speed,sub-delay,video-aspect-override,video-pan-x,video-pan-y,video-rotate,video-zoom,volume";
          alang = "jpn,jp,eng,en,enUS,en-US";
          slang = "ara,ar,arME,enm,eng,en,enUS,en-US";

          # UI
          autofit = "50%";
          border = false;
          term-osd-bar = true;
          cursor-autohide = 1000;
          force-window = "yes";
          geometry = "99%:99%";
          autofit-larger = "90%x90%";
          autofit-smaller = "20%x20%";

          # Colorspace
          # vf = "format=colorlevels=full:colormatrix=auto";
          video-output-levels = "full";

          # Debanding
          deband = true;
          deband-iterations = 4;
          deband-threshold = 30;
          deband-grain = 5;

          # Motion Interpolation
          video-sync = "display-resample";
          interpolation = true;
          tscale = "oversample";

          # Anti-Ringing
          scale-antiring = 0.6;
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          macos-title-bar-appearance = "vibrantDark";
          macos-title-bar-material = "popover";
          macos-fs-animation-duration = 0;
        };
      profiles = {
        big-cache = {
          cache = true;
          demuxer-max-bytes = "2GiB";
          demuxer-readahead-secs = 30;
        };

        network = {
          profile-desc = "profile for content over network";
          profile = "big-cache";
          network-timeout = 5;
          hls-bitrate = "max";
          cache-pause = false;
        };
        "protocol.http" = {profile = "network";};
        "protocol.https" = {profile = "network";};
        "protocol.ytdl" = {profile = "network";};
      };
    };
    yt-dlp = {
      enable = true;
      settings = {
        concurrent-fragments = 20;
        add-metadata = true;
        write-sub = true;
        sub-format = "ass/srt/best";
        sub-lang = "ar,en";
        no-overwrites = true;
        min-sleep-interval = 15;
        max-sleep-interval = 30;
      };
    };
  };
}
