-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   A U T O S T A R T                                                      │
-- │   processes launched with the session                                    │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Quickshell owns org.freedesktop.Notifications, so no separate notification
-- daemon runs: only one process can hold that bus name.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -d")        -- · bar and notifications (quickshell)
    hl.exec_cmd("awww-daemon")  -- · wallpaper
end)

-- · plugins (see input.lua, look.lua)
--
-- nixos: hyprpm cannot build plugins on NixOS. They are built by Nix against
-- this exact Hyprland and loaded from nixos-config, so nothing runs here.

-- · keyring: KWallet, unlocked with the login password as under Plasma, so
-- · gh, browsers and editors find their credentials. nixos: the path is the
-- · system profile's (environment.pathsToLink has /libexec).
hl.on("hyprland.start", function()
    hl.exec_cmd("/run/current-system/sw/libexec/pam_kwallet_init")
end)

-- · polkit agent
--
-- The shell is the session's agent and asks on the island; it starts the
-- KDE agent itself if it cannot register, so none is started here.
