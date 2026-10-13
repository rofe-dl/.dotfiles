return {
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    priority = 1000,
  },

  {
    "Iosevka nerd font catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000,
  },

  {
    "AlexvZyl/nordic.nvim",
    name = "nordic",
    priority = 1000,
  },

  {
    "Mofiqul/adwaita.nvim",
    name = "adwaita",
    priority = 1000,
  },

  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
  },

  {
    "sainnhe/everforest",
    name = "everforest",
    priority = 1000,
  },

  {
    "mellow-theme/mellow.nvim",
    name = "mellow",
    priority = 1000,
  },

  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    priority = 1000,
    lazy = false,
    config = function() vim.cmd.colorscheme "nightfly" end,
  },
}
