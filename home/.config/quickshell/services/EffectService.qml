// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   E F F E C T   S E R V I C E                                            │
// │   wallpaper effects · ImageMagick filters over the painting              │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../theme"

// After JaKooLit's Hyprland-Dots: a filter over the current painting, chosen
// from the launcher's effects mode. theme_manager.py writes the filtered
// still to the cache and answers its path, which is then applied like any
// wallpaper, so the transition and the palette follow. A second effect starts
// again from the painting; "none" goes back to it.
QtObject {
    id: root

    readonly property string script: Quickshell.shellPath("scripts/theme_manager.py")

    // Ids are theme_manager.py's WALLPAPER_EFFECTS keys, "none" aside.
    readonly property var effects: [
        { id: "none",      icon: "󰸉", label: "No effect",     detail: "The painting as it is" },
        { id: "edge",      icon: "󰃣", label: "Edge detect",   detail: "Only the outlines, glowing on black" },
        { id: "bw",        icon: "󰋩", label: "Black & white", detail: "Grey, with the contrast pushed" },
        { id: "sepia",     icon: "󰋩", label: "Sepia",         detail: "An old photograph" },
        { id: "charcoal",  icon: "󰏬", label: "Charcoal",      detail: "Drawn in charcoal" },
        { id: "oil",       icon: "󰏘", label: "Oil paint",     detail: "Thicker strokes" },
        { id: "emboss",    icon: "󰏘", label: "Emboss",        detail: "Pressed into the paper" },
        { id: "pixelate",  icon: "󰋙", label: "Pixelate",      detail: "Big square pixels" },
        { id: "posterize", icon: "󰋙", label: "Posterize",     detail: "A handful of flat colours" },
        { id: "negate",    icon: "󰌁", label: "Negate",        detail: "Every colour inverted" },
        { id: "solarize",  icon: "󰌁", label: "Solarize",      detail: "The light parts inverted" },
        { id: "blur",      icon: "󰂵", label: "Blur",          detail: "Out of focus" },
        { id: "sharpen",   icon: "󰂵", label: "Sharpen",       detail: "Crisper edges" },
        { id: "vignette",  icon: "󰹞", label: "Vignette",      detail: "The corners faded to black" }
    ]

    property bool busy: false

    function search(term: string): var {
        const lead = []
        const rest = []
        for (const effect of root.effects) {
            const name = Tr.t(effect.label)
            const entry = {
                kind: "effect", id: effect.id, icon: effect.icon,
                name: name, subtitle: Tr.t(effect.detail)
            }
            const lower = name.toLowerCase()
            if (term === "" || lower.startsWith(term))
                lead.push(entry)
            else if (lower.includes(term) || entry.subtitle.toLowerCase().includes(term))
                rest.push(entry)
        }
        return lead.concat(rest)
    }

    function apply(id: string): void {
        const current = WallpaperService.currentWallpaper
        if (current === "" || root.busy)
            return
        root.busy = true
        if (id !== "none")
            OsdService.requested("󰏘", Tr.t("Applying the effect…"), -1)
        root.maker.command = [root.script, "make-effect", current, id]
        root.maker.running = true
    }

    readonly property Process maker: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path !== "" && path !== WallpaperService.currentWallpaper)
                    WallpaperService.apply(path)
            }
        }
        onExited: exitCode => {
            root.busy = false
            if (exitCode !== 0)
                OsdService.requested("󰀦", Tr.t("Could not apply the effect"), -1)
        }
    }
}
