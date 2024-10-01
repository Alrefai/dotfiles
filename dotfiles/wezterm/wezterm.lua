local wezterm = require("wezterm")

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"
custom.foreground = "#b3b1ad"
custom.tab_bar.background = "#040404"
custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
custom.tab_bar.new_tab.bg_color = "#080808"

return {
	front_end = "WebGpu",
	audible_bell = "Disabled",
	native_macos_fullscreen_mode = true,
	adjust_window_size_when_changing_font_size = false,
	window_decorations = "RESIZE",
	font = wezterm.font_with_fallback({
		-- "Monaspace Neon",
		-- "Monaspace Argon",
		-- "Monaspace Krypton",
		"JetBrains Mono",
		-- "JetBrainsMono Nerd Font",
		-- "FiraCode Nerd Font",
		-- 'Menlo'
		{ family = "Symbols Nerd Font Mono", weight = "DemiLight" },
		-- 'Symbols Nerd Font Mono',
	}),
	-- freetype_load_target = 'Light',
	-- font_antialias = "Subpixel", -- None, Greyscale, Subpixel
	-- font_hinting = "Full",  -- None, Vertical, VerticalSubpixel, Full
	-- bold_brightens_ansi_colors = true,
	-- allow_square_glyphs_to_overflow_width = 'Never',
	-- allow_width_overflow = true,
	-- freetype_render_target = 'HorizontalLcd',
	-- freetype_load_flags = 'NO_HINTING',
	-- freetype_load_flags = 'NO_HINTING|MONOCHROME',
	font_size = 13,
	-- line_height = 1.2,
	-- cell_width = 1.2,
	harfbuzz_features = {
		-- Monaspace features:
		-- 'liga',
		-- 'calt',
		-- 'dlig',
		-- 'ss01',
		-- 'ss02',
		-- 'ss03',
		-- 'ss04',
		-- 'ss05',
		-- 'ss06',
		-- 'ss07',
		-- 'ss08',
		-- JetBrainsMono features:
		"cv07", -- `Ww` with lover middle connection
		"cv11", -- `y` with different ascender construction
		"cv12", -- `u` with traditional construction
		"cv14", -- `$` with broken bar
	},
	-- color_scheme = 'GitHub Dark Default',
	-- color_scheme = "Catppuccin Mocha", -- Mocha or Macchiato, Frappe, Latte
	color_schemes = { ["OLEDppuccin"] = custom },
	color_scheme = "OLEDppuccin",
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	-- window_background_opacity = 0.90,
	-- macos_window_background_blur = 19,
	-- text_background_opacity = 0.7,
	send_composed_key_when_right_alt_is_pressed = false,
	bidi_enabled = true,
}
