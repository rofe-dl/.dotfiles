-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.fn.system "kitty @ set-spacing padding=0" end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function() vim.fn.system "kitty @ set-spacing padding=default" end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open Neo-tree on startup without hiding the dashboard",
  callback = function()
    -- Only run if Neovim is opened completely empty (e.g., just `nvim`)
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      -- Schedule execution to let Alpha dashboard render completely first
      vim.schedule(function()
        -- 1. Open Neo-tree
        vim.cmd "Neotree show"
        -- 2. Move focus back to the center dashboard pane
        vim.cmd "wincmd p"
      end)
    end
  end,
})

-- Create an autocommand group for theme resetting
local theme_reset_group = vim.api.nvim_create_augroup("ThemeReset", { clear = true })
-- Previewing or switching to light themes messes up the colors of that session, so this resets them upon switching themes
vim.api.nvim_create_autocmd("ColorSchemePre", {
  group = theme_reset_group,
  callback = function()
    -- 1. Reset the background to dark by default (or let the incoming theme override it)
    vim.o.background = "dark"

    -- 2. Clear all active highlight groups
    vim.cmd "highlight clear"

    -- 3. Reset syntax definitions if syntax highlighting is on
    if vim.fn.exists "syntax_on" == 1 then vim.cmd "syntax reset" end
  end,
})

require "lazy_setup"
require "polish"
