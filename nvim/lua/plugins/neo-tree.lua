return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  enabled = true,
  config = function()
    require("neo-tree").setup({
      sources = { "filesystem", "git_status", "buffers", "document_symbols" },
      source_selector = {
        winbar = true,
        statusline = false,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            --"node_modules"
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            ".gitignored",
            ".gitignore",
          },
          always_show_by_pattern = { -- uses glob style patterns
            ".env*",
            "*.env*",
          },
          use_libuv_file_watcher = true,
        },
      },
    })
  end,
}
