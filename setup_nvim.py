'''
This script creates a modular Neovim configuration structure in Python,
equivalent to the provided PowerShell script.
'''
import os
from pathlib import Path

def main():
    '''Main function to set up the Neovim configuration.'''
    # On Windows, this gets the path to %LocalAppData%.
    # On other systems, it might require a different approach (e.g., XDG_CONFIG_HOME).
    local_app_data = os.getenv('LOCALAPPDATA')
    if not local_app_data:
        print("Error: LOCALAPPDATA environment variable not found.")
        print("This script is configured for Windows.")
        return

    nvim_config_dir = Path(local_app_data) / 'nvim'

    # Check if the directory already exists.
    if nvim_config_dir.exists():
        print(f"Directory {nvim_config_dir} already exists. Skipping creation.")
    else:
        print(f"Creating directory structure for Neovim in {nvim_config_dir}...")
        
        # Define and create the main directories.
        # The `parents=True` argument works like `mkdir -p`.
        (nvim_config_dir / 'lua' / 'config').mkdir(parents=True, exist_ok=True)
        (nvim_config_dir / 'lua' / 'plugins').mkdir(parents=True, exist_ok=True)
        (nvim_config_dir / 'ftplugin').mkdir(parents=True, exist_ok=True)
        
        # Create the core files.
        (nvim_config_dir / 'init.lua').touch()
        (nvim_config_dir / 'lua' / 'config' / 'lazy.lua').touch()
        (nvim_config_dir / 'lua' / 'config' / 'keymaps.lua').touch()
        (nvim_config_dir / 'lua' / 'config' / 'options.lua').touch()
        
        print(f"Directory structure created successfully at {nvim_config_dir}")

    # Define the content for init.lua
    init_content = '''
  require("config.lazy")
  require("config.options")
  require("config.keymaps")
'''
    # Write the content to init.lua
    init_lua_path = nvim_config_dir / 'init.lua'
    init_lua_path.write_text(init_content, encoding='utf-8')

    # Define the content for lazy.lua
    lazy_content = '''local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
  -- This tells lazy.nvim to automatically load all .lua files
  -- from the 'lua/plugins' directory and all its subdirectories.
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
'''
    # Write the content to lazy.lua
    lazy_lua_path = nvim_config_dir / 'lua' / 'config' / 'lazy.lua'
    lazy_lua_path.write_text(lazy_content, encoding='utf-8')

    print("Script execution completed.")

if __name__ == "__main__":
    main()