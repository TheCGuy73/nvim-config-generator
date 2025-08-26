$scriptPath = $PSScriptRoot
$nvimConfigPath = Join-Path -Path $scriptPath -ChildPath "nvim"
$luaPath = Join-Path -Path $nvimConfigPath -ChildPath "lua"
$corePath = Join-Path -Path $luaPath -ChildPath "core"
$pluginsPath = Join-Path -Path $luaPath -ChildPath "plugins"
$pluginConfigsPath = Join-Path -Path $pluginsPath -ChildPath "plugins"
$initFile = Join-Path -Path $nvimConfigPath -ChildPath "init.lua"
$coreMappingsFile = Join-Path -Path $corePath -ChildPath "mappings.lua"
$coreOptionsFile = Join-Path -Path $corePath -ChildPath "options.lua"
$coreAutocmdsFile = Join-Path -Path $corePath -ChildPath "autocmds.lua"
$lazyBootstrapFile = Join-Path -Path $pluginsPath -ChildPath "lazy.lua"
$pluginsFile = Join-Path -Path $pluginsPath -ChildPath "plugins.lua"

New-Item -Path $pluginConfigsPath -ItemType Directory -Force | Out-Null
New-Item -Path $corePath -ItemType Directory -Force | Out-Null
New-Item -Path $initFile -ItemType File -Force | Out-Null
New-Item -Path $coreMappingsFile -ItemType File -Force | Out-Null
New-Item -Path $coreOptionsFile -ItemType File -Force | Out-Null
New-Item -Path $coreAutocmdsFile -ItemType File -Force | Out-Null
New-Item -Path $lazyBootstrapFile -ItemType File -Force | Out-Null
New-Item -Path $pluginsFile -ItemType File -Force | Out-Null

Add-Content -Path $initFile -Value @"
require("core.options")
require("core.mappings")
require("core.autocmds")
require("plugins")
"@

Add-Content -Path $lazyBootstrapFile -Value @"
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
"@

Add-Content -Path $pluginsFile -Value @"
require("plugins.lazy")

local plugins = {}
local plugin_specs_path = vim.fn.stdpath("config") .. "/lua/plugins/plugins"
for _, file in ipairs(vim.fn.readdir(plugin_specs_path)) do
    if file:match(".lua$") then
        local plugin_table = require("plugins.plugins." .. file:gsub(".lua$", ""))
        if type(plugin_table) == "table" then
            for _, spec in ipairs(plugin_table) do
                table.insert(plugins, spec)
            end
        end
    end
end

require("lazy").setup(plugins)
"@

Remove-Item -Path $MyInvocation.MyCommand.Path -Force