local wezterm = require("wezterm")
local config = wezterm.config_builder()

--
-- OS detection and SUPER key mapping
--
local function get_os()
  if wezterm.target_triple:find("darwin") then
    return "darwin"
  elseif wezterm.target_triple:find("windows") then
    return "windows"
  else
    return "linux"
  end
end

local os = get_os()
-- Determine the modifier key for SUPER based on OS
-- On macOS, SUPER is the Command key, on Linux and Windows, it's usually CTRL
local SUPER = (os == "darwin") and "CMD" or "CTRL"

--
-- Visuals
--
config.font = wezterm.font("SauceCodePro Nerd Font")
if os == "darwin" then
  -- On macOS, use a larger font size for better readability
  config.font_size = 16
else
  -- On Linux and Windows, use a smaller font size
  config.font_size = 14
end
config.window_background_opacity = 0.9

--
-- Key bindings
--
config.keys = {
  -- Tab Navigation
  {
    key = "RightArrow",
    mods = SUPER,
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "LeftArrow",
    mods = SUPER,
    action = wezterm.action.ActivateTabRelative(-1),
  },

  -- Direct tab access (1-9)
  { key = "1", mods = SUPER, action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = SUPER, action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = SUPER, action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = SUPER, action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = SUPER, action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = SUPER, action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = SUPER, action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = SUPER, action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = SUPER, action = wezterm.action.ActivateTab(8) },

  -- Tab management
  {
    key = "r",
    mods = SUPER .. "|SHIFT",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- Split Panel
  {
    key = "d",
    mods = SUPER,
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "d",
    mods = SUPER .. "|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "LeftArrow",
    mods = SUPER .. "|ALT",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "RightArrow",
    mods = SUPER .. "|ALT",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "DownArrow",
    mods = SUPER .. "|ALT",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "UpArrow",
    mods = SUPER .. "|ALT",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },

  -- Quick shell launchers
  {
    key = "t",
    mods = SUPER .. "|SHIFT",
    action = wezterm.action.ShowLauncher,
  },
}

--
-- setting the shell
--
config.launch_menu = {}

-- Helper function to get shell path if command exists, empty string otherwise
local function shell_path(cmd)
  local command
  if os == "windows" then
    command = "where " .. cmd .. " 2>nul"
  else
    -- On macOS/Linux, try multiple common paths
    local common_paths = {
      "/usr/local/bin/" .. cmd,
      "/opt/homebrew/bin/" .. cmd,
      "/usr/bin/" .. cmd,
      "/bin/" .. cmd,
    }

    -- First try which command
    command = "which " .. cmd .. " 2>/dev/null"
    local handle = io.popen(command)
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and result ~= "" then
        local path = result:match("^%s*(.-)%s*$"):match("([^\r\n]*)")
        if path and path ~= "" then
          return path
        end
      end
    end

    -- If which failed, try common paths directly
    for _, path in ipairs(common_paths) do
      local test_handle = io.popen("test -x '" .. path .. "' && echo '" .. path .. "' 2>/dev/null")
      if test_handle then
        local test_result = test_handle:read("*a")
        test_handle:close()
        if test_result and test_result ~= "" then
          local found_path = test_result:match("^%s*(.-)%s*$"):match("([^\r\n]*)")
          if found_path and found_path ~= "" then
            return found_path
          end
        end
      end
    end

    return ""
  end

  local handle = io.popen(command)
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result and result ~= "" then
      -- Remove trailing whitespace/newlines and return first line only
      local path = result:match("^%s*(.-)%s*$"):match("([^\r\n]*)")
      return path or ""
    end
  end
  return ""
end

-- Debug function to log what shells are found (optional - can be removed)
-- local function debug_shell_detection()
--   local shells = { "zsh", "bash", "fish", "nu", "pwsh" }
--   if os == "windows" then
--     shells = { "zsh", "bash", "fish", "nu.exe", "pwsh.exe" }
--   end

--   wezterm.log_info("=== Shell Detection Debug ===")
--   for _, shell in ipairs(shells) do
--     local path = shell_path(shell)
--     wezterm.log_info(shell .. ": " .. (path ~= "" and path or "NOT FOUND"))
--   end
--   wezterm.log_info("OS: " .. os)
--   wezterm.log_info("============================")
-- end

-- Run debug (comment out if not needed)
-- debug_shell_detection()

-- Add Zsh
if os ~= "windows" then
  local zsh_path = shell_path("zsh")
  if zsh_path ~= "" then
    table.insert(config.launch_menu, {
      label = "Zsh",
      args = { zsh_path, "-l" },
    })
  end
end

-- Add Bash
if os == "windows" then
  table.insert(config.launch_menu, {
    label = "Git Bash",
    args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" },
  })
else
  -- Configure for Linux and macOS
  local bash_path = shell_path("bash")
  if bash_path ~= "" then
    table.insert(config.launch_menu, {
      label = "Bash",
      args = { bash_path, "-l" },
    })
  end
end

-- Add Fish
if os ~= "windows" then
  local fish_path = shell_path("fish")
  if fish_path ~= "" then
    table.insert(config.launch_menu, {
      label = "Fish",
      args = { fish_path, "-l" },
    })
  end
end

-- Add NuShell (cross-platform)
local nu_cmd = (os == "windows") and "nu.exe" or "nu"
local nu_path = shell_path(nu_cmd)
if nu_path ~= "" then
  table.insert(config.launch_menu, {
    label = "Nushell",
    args = { nu_path },
  })
end

-- Platform-specific shells and default configuration
if os == "windows" then
  config.default_prog = { "powershell.exe", "-NoLogo" }

  -- Add PowerShell 7 if available
  local pwsh_path = shell_path("pwsh.exe")
  if pwsh_path ~= "" then
    table.insert(config.launch_menu, {
      label = "PowerShell 7",
      args = { pwsh_path },
    })
  end

  -- Add Windows PowerShell
  table.insert(config.launch_menu, {
    label = "Windows PowerShell",
    args = { "powershell.exe", "-NoLogo" },
  })

  -- Add Command Prompt
  table.insert(config.launch_menu, {
    label = "Command Prompt",
    args = { "cmd.exe" },
  })
else
  -- Set default shell for Unix-like systems (prioritize zsh > fish > bash)
  local zsh_path = shell_path("zsh")
  local fish_path = shell_path("fish")
  local bash_path = shell_path("bash")

  if zsh_path ~= "" then
    config.default_prog = { zsh_path, "-l" }
  elseif fish_path ~= "" then
    config.default_prog = { fish_path, "-l" }
  elseif bash_path ~= "" then
    config.default_prog = { bash_path, "-l" }
  end

  -- Add PowerShell 7 for Unix (if installed via cross-platform package)
  local pwsh_path = shell_path("pwsh")
  if pwsh_path ~= "" then
    table.insert(config.launch_menu, {
      label = "PowerShell 7",
      args = { pwsh_path },
    })
  end
end

if os == "windows" then
  -- Scan for installed WSL distributions and add them to the menu
  local success, wsl_list = wezterm.run_child_process({ "wsl", "-l", "-q" })
  if success and wsl_list then
    for line in string.gmatch(wsl_list, "[^\r\n]+") do
      -- Remove BOM, null bytes, and other control characters
      local distro = line:gsub("[\0-\31\127-\255]", "")
      -- Trim whitespace
      distro = distro:gsub("^%s*", ""):gsub("%s*$", "")
      -- Remove default distribution marker (asterisk)
      distro = distro:gsub("%*", "")
      -- Trim again after removing asterisk
      distro = distro:gsub("^%s*", ""):gsub("%s*$", "")

      -- Only add if we have a non-empty string
      if distro and distro ~= "" and distro:match("%S") then
        table.insert(config.launch_menu, {
          label = "WSL: " .. distro,
          args = { "wsl", "-d", distro },
        })
      end
    end
  end
end

return config
