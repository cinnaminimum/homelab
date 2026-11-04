---Configuration for cinnaminimum.homelab
---@see docs https://cinnaminimum.codeberg.page/homelab/
---@see repo https://codeberg.org/cinnaminimum/homelab
---@class ProjectConfig
local M = {}

---Autocmd group for the configuration
---@private
---@type integer
M.augroup = nil

---Filetypes to register with neovim
---@private
---@type vim.filetype.add.filetypes
M.filetypes = {
  extension = {
    ["build"] = "ini",
    ["j2"] = "jinja",
    ["network"] = "ini",
    ["volume"] = "ini",
  }
}

---Run the configuration setup
---@public
M.setup = function()
  M.augroup = vim.api.nvim_create_augroup("ProjectConfig", {})

  M.setup_ansible()
  M.setup_conform()
  M.setup_filetypes()
  M.setup_lint()
  M.setup_lsp()
  M.setup_treesitter()
end

---Set up ansible-vim
---@private
M.setup_ansible = function()
  vim.pack.add({ "https://github.com/pearofducks/ansible-vim" })
  require("ansible").setup()

  -- Kill the autocmd groups that set filetypes
  vim.api.nvim_create_augroup("ansible_vim_ftyaml_ansible", {})
  vim.api.nvim_create_augroup("ansible_vim_ftjinja2", {})
  vim.api.nvim_create_augroup("ansible_vim_fthosts", {})

  vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name:match(".*/files/.*%.yml") or
          name:match(".*/meta/.*%.yml") or
          name:match(".*/templates/.*%.yml") then
        return
      end
      vim.bo.filetype = "ansible"
    end,

    desc = "Set ansible filetype",
    group = M.augroup,
    pattern = {
      "*/roles/*/*.yml",
      "*/tests/integration/targets/*/*/*.yml",
    },
  })
end

---Set up conform.nvim
---@private
M.setup_conform = function()
  vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
  local conform = require("conform")

  conform.formatters_by_ft = conform.formatters_by_ft or {}
  conform.formatters_by_ft["markdown"] = { "rumdl" }
  conform.formatters_by_ft["python"] = { "ruff_fix", "ruff_organize_imports", "ruff_format" }
  conform.formatters_by_ft["toml"] = { "tombi" }
  conform.formatters_by_ft["yaml.ansible"] = { "ansible-lint" }
end

---Register filetypes with neovim
---@private
M.setup_filetypes = function()
  vim.filetype.add(M.filetypes)
end

---Set up nvim-lint
---@private
M.setup_lint = function()
  vim.pack.add({ "https://codeberg.org/mfussenegger/nvim-lint" })
  local lint = require("lint")

  lint.linters_by_ft = lint.linters_by_ft or {}
  lint.linters_by_ft.gitcommit = { "commitlint" }

  lint.linters = lint.linters or {}
  lint.linters.commitlint = lint.linters.commitlint or {}
  lint.linters.commitlint.args = lint.linters.commitlint.args or {}
  vim.list_extend(lint.linters.commitlint.args, { "--config", ".config/commitlint.yml" })
end

---Set up lsp
---@private
M.setup_lsp = function()
  vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

  vim.lsp.config('ruff', {
    init_options = {
      settings = {
        configuration = ".config/ruff.toml",
      },
    },
  })

  vim.lsp.enable({
    "ansiblels",
    "jsonls",
    "ruff",
    "rumdl",
    "tombi",
    "ty",
    "yamlls",
  })
end

---Set up tree-sitter
---@private
M.setup_treesitter = function()
  vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
  local treesitter = require("nvim-treesitter")

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

  for extension, filetype in pairs(M.filetypes.extension) do
    -- Make type checker happy
    if type(filetype) ~= "string" then
      error()
    end

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
    group = M.augroup,
    pattern = filetypes,
  })
end

M.setup()
