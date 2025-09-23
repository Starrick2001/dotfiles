return {
  "milanglacier/minuet-ai.nvim",
  enabled = true,
  config = function()
    require("minuet").setup({
      -- Your configuration options here
      provider = "openai_fim_compatible",
      n_completions = 3, -- recommend for local model for resource saving
      -- I recommend beginning with a small context window size and incrementally
      -- expanding it, depending on your local computing power. A context window
      -- of 512, serves as an good starting point to estimate your computing
      -- power. Once you have a reliable estimate of your local computing power,
      -- you should adjust the context window to a larger value.
      -- context_window = 512,
      context_window = 768,
      context_ratio = 0.75,
      request_timeout = 10,
      blink = {
        enable_auto_complete = true,
      },
      stream = true,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          -- end_point = "http://localhost:1234/v1/completions",
          model = "qwen2.5-coder:0.5b",
          -- model = "deepseek-coder-v2-lite-instruct-mlx",
          -- model = "stable-code-instruct-3b@q6_k",
          -- model = "llama3.1",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
    })
  end,
}
