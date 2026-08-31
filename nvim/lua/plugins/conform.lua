return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "never" })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  opts = function()
    require("conform").setup({
      notify_on_error = true,
      stop_after_first = true,
      formatters_by_ft = {
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        vtsls = { "biome", "prettier", stop_after_first = true },
      },
      formatters = {
        biome = {
          require_cwd = true, -- Only runs if biome.json is found in the project root
        },
        prettier = {
          cwd = require("conform.util").root_file({ ".prettierrc", "package.json" }),
        },
      },
      default_format_opts = {
        -- lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        local ignore_filetypes = { "sql", "yaml", "yml" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("/node_modules/") then
          return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    })
  end,
}
