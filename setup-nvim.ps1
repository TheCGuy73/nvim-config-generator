# Requires PowerShell 5.1 or later.
# This script will create a modular Neovim configuration structure.

# Define the base directory for Neovim config using %LocalAppData%.
$NVIM_CONFIG_DIR = "$env:LocalAppData\nvim"

# Check if the directory already exists.
if (Test-Path -Path $NVIM_CONFIG_DIR) {
    Write-Host "Directory $NVIM_CONFIG_DIR already exists. Skipping creation."
} else {
    Write-Host "Creating directory structure for Neovim in %LocalAppData%..."
    
    # Create the main directories.
    $null = New-Item -ItemType Directory -Path "$NVIM_CONFIG_DIR\lua\config" -Force
    $null = New-Item -ItemType Directory -Path "$NVIM_CONFIG_DIR\lua\plugins" -Force
    $null = New-Item -ItemType Directory -Path "$NVIM_CONFIG_DIR\ftplugin" -Force
    
    # Create the core files.
    $null = New-Item -ItemType File -Path "$NVIM_CONFIG_DIR\init.lua"
    $null = New-Item -ItemType File -Path "$NVIM_CONFIG_DIR\lua\config\lazy.lua"
    $null = New-Item -ItemType File -Path "$NVIM_CONFIG_DIR\lua\config\keymaps.lua"
    $null = New-Item -ItemType File -Path "$NVIM_CONFIG_DIR\lua\config\options.lua"
    
    Write-Host "Directory structure created successfully at $NVIM_CONFIG_DIR"
}

# Add initial content to init.lua
$initContent = @'
-- Set options and keymaps
require("config.options")
require("config.keymaps")

-- Initialize and configure Lazy
require("config.lazy")
'@

$initContent | Out-File -FilePath "$NVIM_CONFIG_DIR\init.lua" -Encoding UTF8 -Force

# Add initial content to lazy.lua
$lazyContent = @'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- The following imports your plugin configurations
  { import = "plugins" },
}, {
  -- Lazy options
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
'@

$lazyContent | Out-File -FilePath "$NVIM_CONFIG_DIR\lua\config\lazy.lua" -Encoding UTF8 -Force

Write-Host "Script execution completed."