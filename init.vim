set number
set clipboard+=unnamedplus
call plug#begin()

" Fancy Status bar
"Plug 'itchyny/lightline.vim'
Plug 'yamatsum/nvim-cursorline',{'branch':'main'}
" Fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh' }
" Language Server Protocal
Plug 'neovim/nvim-lspconfig'
Plug 'SmiteshP/nvim-navic'
Plug 'ray-x/lsp_signature.nvim'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'hrsh7th/cmp-path', {'branch': 'main'}
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'feline-nvim/feline.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'tag':'0.1.5'}
Plug 'gennaro-tedesco/nvim-possession'
Plug 'ibhagwan/fzf-lua'
call plug#end()


let g:rooter_patterns = ['.git']
let g:fzf_layout = { 'window': { 'width': 0.5, 'height': 0.4, 'xoffset':0, 'yoffset':1 } }
let g:fzf_vim = {}
" Preview window is hidden by default. You can toggle it with ctrl-/.
" It will show on the right with 50% width, but if the width is smaller
" than 70 columns, it will show above the candidate list
let g:fzf_vim.preview_window = ['hidden,right,50%,<70(up,40%)', 'ctrl-/']

"let g:lightline = {
"      \ 'component_function': {
"      \   'filename': 'LightlineFilename',
"      \ }
"      \ }

function! LightlineFilename()
  "let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let root = FindRootDirectory()
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

map <C-J> :bnext<CR>
map <C-K> :bprev<CR>

set hidden
"let g:LanguageClient_serverCommands = {
"  \ 'cpp': ['clangd'],
"  \ 'c':['clangd'],
"  \ }

"nmap <silent> gd <Plug>(lcn-definition)
"nmap <silent> gr <Plug>(lcn-references)
" LSP configuration
lua << END
local opt=vim.opt
opt.ignorecase = true
opt.smartcase = true
opt.relativenumber = true
opt.tgc = true
require('felinecolors')
require('gitsigns').setup()
require('nvim-cursorline').setup{
  	cursorline = {
		enable = true,
		timeout = 1000,
		number = false,
	  },
	  cursorword = {
		  enable = true,
		  min_length = 3,
		  hl={underline=true},
		  }
}

local possession=require("nvim-possession")

possession.setup({
sessions = {
	sessions_path="/home/songjiang/nvim-possessions/",
	}
})

vim.keymap.set({"n"},"<leader>sl",function()
	possession.list()
	end)

vim.keymap.set({"n"},"<leader>sn",function()
	possession.new()
	end)

vim.keymap.set({"n"},"<leader>su",function()
	possession.update()
	end)

vim.keymap.set({"n"},"<leader>sd",function()
	possession.delete()
	end)



local feline_components = {
	active = {{},{}},
	inactive = {{},{}}
}
table.insert(feline_components.inactive[1],{
	provider = { name = "file_info", opts = { type = "relative" } },
	hl="StatusLine" 
})

table.insert(feline_components.inactive[2],{
	provider = "position",
	hl="StatusLine"
})


local u=require('felineutil')

local function vi_mode_hl()
  return u.vi.colors[vim.fn.mode()] or "FlnViBlack"
end

local function vi_sep_hl()
  return u.vi.sep[vim.fn.mode()] or "FlnBlack"
end

local get_diag = function(str)
  local count = vim.lsp.diagnostic.get_count(0, str)
  return (count > 0) and " " .. count .. " " or ""
end

table.insert(feline_components.active[1],{
  provider = function()
      return string.format(" %s ", u.vi.text[vim.fn.mode()])
    end,
    hl = vi_mode_hl,
    --right_sep = { str = " ", hl = vi_sep_hl },
})

table.insert(feline_components.active[1],{
	provider = "git_branch",
    	icon = " ",
    	hl = "FlnGitBranch",
	left_sep = { str = u.icons.left, hl = "FlnAlt" },
    	right_sep = { str = "  ", hl = "FlnGitBranch" },
    	enabled = function()
      		return vim.b.gitsigns_status_dict ~= nil
    		end,
})

table.insert(feline_components.active[1],{
    provider = { name = "file_info", opts = { type = "relative" } },
    hl = "FlnAltSep",
    left_sep = { str = u.icons.left, hl = "FlnAlt" },
    --right_sep = { str = "", hl = "FlnAlt" },
  }
)

table.insert(feline_components.active[1],{
	provider = "",
	hl = "StatusLine",
})

--table.insert(feline_components.active[2],{
--    provider = function()
--      return require("lsp-status").status()
--    end,
--    hl = "FlnStatus",
--    left_sep = { str = "", hl = "FlnStatusBg", always_visible = true },
--    right_sep = { str = "", hl = "FlnErrorStatus", always_visible = true },
--})

--table.insert(feline_components.active[2],{
--provider = function()
--      return get_diag("Error")
--    end,
--    hl = "FlnError",
--    right_sep = { str = "", hl = "FlnWarnError", always_visible = true },
--  })
--table.insert(feline_components.active[2],{
--provider = function()
--      return get_diag("Warning")
--    end,
--    hl = "FlnWarn",
--    right_sep = { str = "", hl = "FlnInfoWarn", always_visible = true },
--})
--table.insert(feline_components.active[2],{
--provider = function()
--      return get_diag("Information")
--    end,
--    hl = "FlnInfo",
--    right_sep = { str = "", hl = "FlnHintInfo", always_visible = true },
--})
local fmt=string.format
table.insert(feline_components.active[2],{
    provider = function()
      return fmt(" %s ", vim.bo.filetype:upper())
    end,
    hl = "FlnAlt",
})
table.insert(feline_components.active[2],{
    provider = function()
      local os = u.icons[vim.bo.fileformat] or ""
      return fmt(" %s %s ", os, vim.bo.fileencoding)
    end,
    hl = "FlnAltSep",
    left_sep = { str = u.icons.left, hl = "FlnAlt" },
})
table.insert(feline_components.active[2],{
    provider = function()
      -- TODO: What about 4+ diget line numbers?
      return fmt(" %3d:%-2d ", unpack(vim.api.nvim_win_get_cursor(0)))
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left_filled, hl = vi_sep_hl },
})
table.insert(feline_components.active[2],{
    provider = function()
      return " " .. require("feline.providers.cursor").line_percentage() .. "  "
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left, hl = vi_mode_hl },
})
table.insert(feline_components.active[2],{
	provider = possession.status,
    	hl = vi_mode_hl,
	left_sep = { str = u.icons.left, hl = vi_mode_hl },
    	enabled = function()
      		return possession.status() ~= nil
    		end,
})


table.insert(feline_components.active[2],{
	})

require('feline').setup({
	components = feline_components
}
)
local cmp=require'cmp'
local navic=require'nvim-navic'

local components = {
	active = {{}, {}, {}},
	inactive = {{}, {} ,{}}
}

table.insert(components.active[1], {
	provider = function()
		return navic.get_location()
	end,
	enabled = function() return navic.is_available() end,
})

table.insert(components.inactive[1], {
	provider = function()
		return navic.get_location()
	end,
	enabled = function() return navic.is_available() end,
})

require("feline").winbar.setup({
	components = components
})



local border = {
	{ "🭽", "FloatBorder" },
	{ "▔", "FloatBorder" },
	{ "🭾", "FloatBorder" },
	{ "▕", "FloatBorder" },
	{ "🭿", "FloatBorder" },
	{ "▁", "FloatBorder" },
	{ "🭼", "FloatBorder" },
	{ "▏", "FloatBorder" },
}

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = border
  }
)
--TRACE,DEBUG,INFO,WARN,ERROR,OFF
vim.lsp.set_log_level(1)

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = border
  }
)

local set_hl_for_floating_window = function()
  vim.api.nvim_set_hl(0, 'NormalFloat', {
    link = 'Normal',
  })
  vim.api.nvim_set_hl(0, 'FloatBorder', {
    bg = none,
  })
end

set_hl_for_floating_window()

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  desc = 'Avoid overwritten by loading color schemes later',
  callback = set_hl_for_floating_window,
})

local lspconfig=require'lspconfig'
local on_attach1 = function(client, bufnr)
  navic.attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true}

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
  buf_set_keymap("v", '<leader>fm', "<cmd>lua vim.lsp.buf.format()<CR>",opts)

  -- Get signatures (and _only_ signatures) when in argument lists.
  require "lsp_signature".on_attach({
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  })
end
lspconfig.clangd.setup {
  on_attach = on_attach1,
  cmd = {"clangd","--log=verbose"}
}

local telescope_builtin = require("telescope.builtin")
vim.keymap.set({"n"},"lds",function()
	telescope_builtin.lsp_document_symbols()
end,{buffer=bufnr})

vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, {})


vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
  "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {
        -- only needed if you want to use the commands with "_with_window_picker" suffix
        's1n7ax/nvim-window-picker',
        tag = "v1.*",
        config = function()
          require'window-picker'.setup({
            autoselect_one = true,
            include_current = false,
            filter_rules = {
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', "neo-tree-popup", "notify" },

                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal', "quickfix" },
              },
            },
            other_win_hl_color = '#e35e4f',
          })
        end,
      }
    },
  }

end)


END
