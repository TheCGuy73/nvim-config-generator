#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

NVIM_CONFIG_PATH="$SCRIPT_DIR/nvim"
LUA_PATH="$NVIM_CONFIG_PATH/lua"
CORE_PATH="$LUA_PATH/core"
PLUGINS_PATH="$LUA_PATH/plugins"
PLUGIN_CONFIGS_PATH="$PLUGINS_PATH/plugins"

INIT_FILE="$NVIM_CONFIG_PATH/init.lua"
CORE_MAPPINGS_FILE="$CORE_PATH/mappings.lua"
CORE_OPTIONS_FILE="$CORE_PATH/options.lua"
CORE_AUTOCMDS_FILE="$CORE_PATH/autocmds.lua"
LAZY_BOOTSTRAP_FILE="$PLUGINS_PATH/lazy.lua"
PLUGINS_FILE="$PLUGINS_PATH/plugins.lua"

mkdir -p "$PLUGIN_CONFIGS_PATH"
mkdir -p "$CORE_PATH"

cat > "$INIT_FILE" << 'EOF'
require("core.options")
require("core.mappings")
require("core.autocmds")
require("plugins")
EOF

cat > "$LAZY_BOOTSTRAP_FILE" << 'EOF'
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
EOF

cat > "$PLUGINS_FILE" << 'EOF'
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
EOF

rm -- "$0"
