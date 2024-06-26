local M = {}

function M.setup(config)
  config.tailwindcss.setup({
    filetypes = { "html", "elixir", "eelixir", "heex" },
    init_options = {
      userLanguages = {
        elixir = "html-eex",
        eelixir = "html-eex",
        heex = "html-eex",
      },
    },
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            'class[:]\\s*"([^"]*)"',
          },
        },
      },
    },
  })
end
return M
