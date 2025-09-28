-- Pull in the wezterm API
local wezterm = require 'wezterm'
wezterm.log_info('✓ WezTerm API loaded successfully!')

-- This table will hold the configuration
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
  wezterm.log_info('✓ Config builder available and used')
else
  wezterm.log_warn('⚠ Config builder not available - using older WezTerm version')
end

-- Font Configuration
wezterm.log_info('→ Configuring fonts and color scheme...')
config.font_size = 12.0

-- Font rules -
config.font_rules = {
  -- Regular text
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font('FiraCode Nerd Font', { weight = 450 }),
  },
  -- Bold text
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font('FiraCode Nerd Font', { weight = 'Medium' }),
  },
  -- Italic text - Use Medium Italic with explicit attributes
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font('Operator Mono', { weight = 'DemiLight', style = 'Italic' }),
  },
  -- Bold italic text - Use Bold Italic with explicit attributes
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font('Operator Mono', { weight = 'Bold', style = 'Italic' }),
  },
}

-- Fallback font (equivalent to font_family in Kitty)
config.font = wezterm.font('FiraCode Nerd Font')

-- Enable ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- GPU renderer (WezTerm auto-detects by default)
config.front_end = 'OpenGL' -- or 'WebGpu' for newer systems

-- Padding (equivalent to padding_width in Kitty)
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}

-- Cursor configuration
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 0  -- 0 disables blinking (matches cursor_blink_interval 0.0)
config.cursor_thickness = 1.0  -- equivalent to cursor_outline_width

-- Catppuccin Mocha color scheme
config.color_scheme = 'Catppuccin Mocha'

-- SOLUTION: Use integrated decorations for dark title bar
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Enhanced color configuration with title bar styling
config.colors = {
  tab_bar = {
    background = '#1e1e2e',  -- Dark background for tab bar
    active_tab = {
      bg_color = '#89b4fa',  -- Blue background for active tab
      fg_color = '#1e1e2e',  -- Dark text on active tab
    },
    inactive_tab = {
      bg_color = '#313244',  -- Dark gray for inactive tabs
      fg_color = '#cdd6f4',  -- Light text on inactive tabs
    },
    inactive_tab_hover = {
      bg_color = '#585b70',  -- Slightly lighter when hovering
      fg_color = '#cdd6f4',
    },
    new_tab = {
      bg_color = '#313244',  -- Dark background for + button
      fg_color = '#cdd6f4',  -- Light text for + button
    },
    new_tab_hover = {
      bg_color = '#585b70',  -- Lighter when hovering over + button
      fg_color = '#cdd6f4',
    },
  },
}

-- Window frame styling for integrated title bar
config.window_frame = {
  -- The font used in the tab bar
  font = wezterm.font({ family = 'FiraCode Nerd Font', weight = 'Bold' }),
  font_size = 11.0,
  
  -- Colors for the title bar area
  active_titlebar_bg = '#1e1e2e',    -- Dark background to match theme
  inactive_titlebar_bg = '#181825',  -- Slightly darker when unfocused
  
  -- Button styling (close, minimize, maximize)
  active_titlebar_fg = '#cdd6f4',    -- Light text/buttons
  inactive_titlebar_fg = '#6c7086',  -- Dimmed when unfocused
  
  active_titlebar_border_bottom = '#313244',
  inactive_titlebar_border_bottom = '#1e1e2e',
}

-- Additional settings
config.enable_tab_bar = true
config.window_close_confirmation = "NeverPrompt"

-- Performance settings
config.max_fps = 120
config.animation_fps = 60

-- Show window title in tab bar
config.show_tab_index_in_tab_bar = false

-- Set default shell (change this to your preferred default)
-- Options: 'powershell', 'pwsh', 'wsl', 'cmd'
config.default_prog = { 'C:/WINDOWS/system32/wsl.exe', '-d', 'Ubuntu-22.04'} 

config.launch_menu = {
  {
    label = 'Ubuntu 22.04 (WSL) - Home',
    args = { 'C:/WINDOWS/system32/wsl.exe', '-d', 'Ubuntu-22.04' },
  },
  {
    label = 'PowerShell 7',
    args = { 'C:/Program Files/PowerShell/7/pwsh.exe' },
    cwd = 'C:/Users/' .. os.getenv('USERNAME'),
  },
  {
    label = 'Windows PowerShell',
    args = { 'powershell.exe' },
  },
}

wezterm.log_info('🎉 Configuration completed successfully!')
return config
