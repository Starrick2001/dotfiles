return {
  "stevearc/conform.nvim",
  opts = function()
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
      },
      formatters = {
        biome = {
          require_cwd = true, -- Only runs if biome.json is found in the project root
        },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    })
  end,
}
