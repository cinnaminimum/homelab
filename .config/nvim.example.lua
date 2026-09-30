local H = {}

H.augroup = vim.api.nvim_create_augroup("ProjectConfig", {})

H.setup = function()
  H.setup_conform()
  H.setup_lint()
  H.setup_lsp()
  H.setup_plugins()
  H.setup_treesitter()
end

H.setup_conform = function()
  local status, conform = pcall(require, "conform")
  if not status then
    return
  end

  conform.formatters_by_ft = conform.formatters_by_ft or {}
  conform.formatters_by_ft["python"] = { "ruff_fix", "ruff_organize_imports", "ruff_format" }
  conform.formatters_by_ft["toml"] = { "tombi" }
  conform.formatters_by_ft["yaml.ansible"] = { "ansible-lint" }
end

H.setup_lint = function()
  local status, lint = pcall(require, "lint")
  if not status then
    return
  end

  lint.linters_by_ft = lint.linters_by_ft or {}
  lint.linters_by_ft.gitcommit = { "commitlint" }

  lint.linters = lint.linters or {}
  lint.linters.commitlint = lint.linters.commitlint or {}
  lint.linters.commitlint.args = lint.linters.commitlint.args or {}
  vim.list_extend(lint.linters.commitlint.args, { "--config", ".config/commitlint.yml" })
end

H.setup_lsp = function()
  if vim.fn.has("nvim-0.11") == 0 then
    return
  end

  vim.lsp.enable({
    "ansiblels",
    "ruff",
    "tombi",
    "ty",
    "yamlls",
  })
end

H.setup_plugins = function()
  if vim.fn.has("nvim-0.12") == 0 then
    return
  end

  vim.pack.add({
    "https://github.com/mfussenegger/nvim-ansible",
  })
end

H.setup_treesitter = function()
  local status, treesitter = pcall(require, "nvim-treesitter")
  if not status then
    return
  end

  local languages = {
    "comment",
    "dockerfile",
    "gitcommit",
    "gitignore",
    "ini",
    "jinja",
    "markdown",
    "python",
    "rst",
    "toml",
    "yaml",
  }
  treesitter.install(languages)

  local extensions = {
    ["build"] = "ini",
    ["j2"] = "jinja",
    ["network"] = "ini",
    ["volume"] = "ini",
  }
  vim.filetype.add({ extension = extensions })

  for extension, filetype in pairs(extensions) do
    vim.treesitter.language.register(filetype, extension)
  end
  vim.treesitter.language.register("jinja", "dockerfile.jinja")

  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
      vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      vim.treesitter.start(ev.buf)
    end,

    desc = "Start tree-sitter",
    group = H.augroup,
    pattern = filetypes,
  })
end

H.setup()
