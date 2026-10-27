-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   P L U G I N S                                                          │
-- │   loaded from the NixOS system profile                                   │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- nixos: hyprpm cannot build on NixOS. nixos-config builds both plugins
-- against this exact Hyprland and links them into the system profile; each
-- is loaded only when it is there, so Arch (hyprpm) is unaffected.
--
-- Their settings stay in input.lua (dynamic_cursors) and look.lua
-- (hyprglass), behind guards that skip them until the plugin is loaded.

local lib = "/run/current-system/sw/lib/"

for _, name in ipairs({ "libhypr-dynamic-cursors.so", "libhyprglass.so" }) do
    local file = io.open(lib .. name)
    if file then
        file:close()
        hl.plugin.load(lib .. name)
    end
end
