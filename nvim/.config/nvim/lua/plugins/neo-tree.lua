return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false, -- Optional: set to false if you also want to see .gitignore'd files
      },
    },
  },
}
