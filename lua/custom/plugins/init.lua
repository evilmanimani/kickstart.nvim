-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*.js", "*.ts" },
  command = "EslintFixAll"
})
vim.g.neovide_transparency = 0.95
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_scale_factor = 0.95
vim.g.neovide_fullscreen = true
vim.g.neovide_cursor_vfx_mode = ""
vim.o.guifont = "FiraCode Nerd Font:h12"
vim.o.shell = "powershell"
vim.g.miniindentscope_disable = true
vim.g.neovide_cursor_trail_size = 0.25
vim.o.showtabline = 0
-- vim.o.softtabstop = 2
-- vim.o.shiftwidth = 2
vim.o.relativenumber = true
-- vim.opt.signcolumn = "number"
local vk = vim.keymap.set

local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  vim.cmd("redraw!")
end
vk("n", "<C-=>", function()
  change_scale_factor(1.11)
end)
vk("n", "<C-->", function()
  change_scale_factor(1 / 1.11)
end)
if vim.g.neovide then
  vk("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { desc = "Toggle fullscreen" })
end


-- Automatically set root to path of current buffer

-- Array of file names indicating root directory. Modify to your liking.
local root_names = { '.git', 'Makefile' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
  -- Get directory path to start search from
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  path = vim.fs.dirname(path) or ''

  -- Try cache and resort to searching upward for root directory
  local root = root_cache[path]
  if root == nil then
    local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
    if root_file == nil then return end
    root = vim.fs.dirname(root_file)
    root_cache[path] = root
  end

  -- Set current directory
  vim.fn.chdir(root)
end

local root_augroup = vim.api.nvim_create_augroup('MyAutoRoot', {})
vim.api.nvim_create_autocmd('BufEnter', { group = root_augroup, callback = set_root })

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<C-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- vk("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selected down" })
-- vk("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selected up" })
vk("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
-- vk("n", "<C-A-o>", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Find symbols" })
vk("i", "jj", "<esc>", { desc = "<ESC>" })
vk(
  "n",
  "<leader>e",
  "<cmd>lua require('mini.files').open(vim.api.nvim_buf_get_name(0), false)<cr>",
  { desc = "[E]xplore mini.files" }
)
-- vk("n", "<C-a>", "za", { desc = "Toggle fold" })
vk("n", "<leader>pj", "<cmd>pu<cr>", { desc = "Paste below" })
vk("n", "<leader>pk", "<cmd>pu!<cr>", { desc = "Paste above" })
vk("n", "<leader>pp", "$p", { desc = "Paste at end of line" })
vk("n", "<leader>?", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
vk("n", "<leader>s?", "<cmd>Cheatsheet<cr>", { desc = "Cheatsheet" })
vk("n", "<leader>m", "<cmd>messages<cr>", { desc = "Show messages" })
-- vk("n", "<C-l>", "<cmd>LspStop<cr>")
vk("v", "<F2>", "<cmd>'<,'>w !node<cr>", { desc = "Execute selection in Node" })
vk("n", "<C-d>", "<C-d>zz")
vk("n", "<C-u>", "<C-u>zz")
vk("n", "<C-u>", "<C-u>zz")
vk("x", "<leader>p", [["_dP]])
vk("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
vk("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
vk("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
--keywordprg
vk("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })
-- Clear search with <esc>
vk({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
-- buffers
vk("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vk("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vk("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vk("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vk("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
-- better up/down
vk({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vk({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vk({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vk({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- Move to window using the <ctrl> hjkl keys
vk("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vk("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vk("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vk("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vk("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vk("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vk("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vk("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

require('which-key').register {
  ['<leader>b'] = { name = '[B]uffer', _ = 'which_key_ignore' },
  ['<leader>p'] = { name = '[P]aste', _ = 'which_key_ignore' },
}

local  ilazy = { 
  misc = {
    dots = "󰇘",
  },
  dap = {
    Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint          = " ",
    BreakpointCondition = " ",
    BreakpointRejected  = { " ", "DiagnosticError" },
    LogPoint            = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn  = " ",
    Hint  = " ",
    Info  = " ",
  },
  git = {
    added    = " ",
    modified = " ",
    removed  = " ",
  },
  kinds = {
    Array         = " ",
    Boolean       = "󰨙 ",
    Class         = " ",
    Codeium       = "󰘦 ",
    Color         = " ",
    Control       = " ",
    Collapsed     = " ",
    Constant      = "󰏿 ",
    Constructor   = " ",
    Copilot       = " ",
    Enum          = " ",
    EnumMember    = " ",
    Event         = " ",
    Field         = " ",
    File          = " ",
    Folder        = " ",
    Function      = "󰊕 ",
    Interface     = " ",
    Key           = " ",
    Keyword       = " ",
    Method        = "󰊕 ",
    Module        = " ",
    Namespace     = "󰦮 ",
    Null          = " ",
    Number        = "󰎠 ",
    Object        = " ",
    Operator      = " ",
    Package       = " ",
    Property      = " ",
    Reference     = " ",
    Snippet       = " ",
    String        = " ",
    Struct        = "󰆼 ",
    TabNine       = "󰏚 ",
    Text          = " ",
    TypeParameter = " ",
    Unit          = " ",
    Value         = " ",
    Variable      = "󰀫 ",
  },
}
return {

  {
    "maxmx03/solarized.nvim",
    config = function()
      vim.o.background = "dark"
      vim.cmd("colo solarized")
    end,
    opts = {
      theme = "neo",
      palette = "solarized",
      -- palette = "selenized",
      transparent = false,
    },
  },
  -- { "lukas-reineke/lsp-format.nvim" },
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({})
      vk("n", "-", require("oil").open, { desc = "Open parent directory" })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>p"] = { name = "+paste" },
      },
    }
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    init = function()
      require("mini.ai").setup({})
      require("mini.files").setup({})
      -- require("mini.notify").setup({})
      require("mini.splitjoin").setup({})
      require("mini.align").setup({})
      require("mini.bracketed").setup({})
      vk("n", "<leader>bd", function()
        local bd = require("mini.bufremove").delete
        if vim.bo.modified then
          local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
          if choice == 1 then -- Yes
            vim.cmd.write()
            bd(0)
          elseif choice == 2 then -- No
            bd(0, true)
          end
        else
          bd(0)
        end
      end, {desc = "Delete Buffer"})
      vk("n", "<leader>bD", function() require("mini.bufremove").delete(0, true) end, {desc = "Delete Buffer (Force)"} )
      require("mini.bufremove").setup({})
      require("mini.move").setup({
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          right = "<M-l>",
          left = "<M-h>",
          down = "<M-j>",
          up = "<M-k>",

          -- Move current line in Normal mode
          line_left = "<M-h>",
          line_right = "<M-l>",
          line_down = "<M-j>",
          line_up = "<M-k>",
        },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        -- stylua: ignore
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        diagnostics_indicator = function(_, _, diag)
          local icons = ilazy.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
    -- config = function(_, opts)
    --   require("bufferline").setup(opts)
    --   -- Fix bufferline when restoring a session
    --   vim.api.nvim_create_autocmd("BufAdd", {
    --     callback = function()
    --       vim.schedule(function()
    --         pcall(nvim_bufferline)
    --       end)
    --     end,
    --   })
    -- end,
  },
  -- {
  --   "akinsho/bufferline.nvim",
  --   config = function()
  --
  --     require("bufferline").setup({
  --       options = {
  --         style_preset = require("bufferline").style_preset.minimal, -- or bufferline.style_preset.minimal,
  --         show_buffer_close_icons = false,
  --         show_close_icon = false,
  --         separator_style = "slant",
  --       },
  --     })
  --   end
  -- },
  -- Finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local separator_style = "round"
      local solarized_palette = require("solarized.palette")
      local colors = solarized_palette.get_colors()

      local custom_theme = {
        normal = {
          a = { fg = colors.base03, bg = colors.blue },
          b = { fg = colors.base02, bg = colors.base1 },
          c = { fg = colors.base2, bg = colors.base03 },
        },
        insert = {
          a = { fg = colors.base03, bg = colors.green },
        },
        visual = {
          a = { fg = colors.base03, bg = colors.magenta },
        },
        replace = {
          a = { fg = colors.base03, bg = colors.red },
        },
        command = {
          a = { fg = colors.base03, bg = colors.red },
        },
        inactive = {
          a = { fg = colors.base02, bg = colors.base1 },
          b = { fg = colors.base2, bg = colors.base04 },
          c = { fg = colors.base04, bg = colors.base04 },
        },
      }

      local hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end

      local sections = {}

      -- local gitsigns = vim.b.gitsigns_status_dict

      local icons = {
        vim = "",
        git = "",
        diff = { added = ilazy.git.added, modified = ilazy.git.modified, removed = ilazy.git.removed },
        default = { left = "", right = " " },
        round = { left = "", right = "" },
        block = { left = "█", right = "█" },
        arrow = { left = "", right = "" },
      }

      local function ins_config(location, component)
        sections["lualine_" .. location] = component
      end

      ins_config("a", {
        {
          "mode",
          icon = icons.vim,
          separator = { left = icons.block.left, right = icons[separator_style].right },
          right_padding = 2,
        },
      })

      ins_config("b", {
        {
          "filename",
          path = 1,
          fmt = function(filename)
            local icon = "󰈚"

            local devicons_present, devicons = pcall(require, "nvim-web-devicons")

            if devicons_present then
              local ft_icon = devicons.get_icon(filename)
              icon = (ft_icon ~= nil and ft_icon) or icon
            end

            return string.format("%s %s", icon, filename)
          end,
        },
      })

      ins_config("c", {
        {
          "branch",
          icon = { icons.git, color = { fg = colors.magenta } },
          -- cond = hide_in_width,
        },
        {
          "diff",
          symbols = icons.diff,
          colored = true,
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
          -- cond = hide_in_width,
        },
      })

      local function fg(name)
        ---@type {foreground?:number}?
        ---@diagnostic disable-next-line: deprecated
        local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
        ---@diagnostic disable-next-line: undefined-field
        local fg = hl and (hl.fg or hl.foreground)
        return fg and { fg = string.format("#%06x", fg) } or nil
      end
      ins_config("x", {
        -- stylua: ignore
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = fg("Statement"),
        },
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = fg("Constant"),
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = fg("Debug"),
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = fg("Special"),
        },
      })

      ins_config("y", {
        {
          "progress",
          fmt = function(progress)
            local spinners = { "󰚀", "󰪞", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰚀" }

            if string.match(progress, "%a+") then
              return progress
            end

            local p = tonumber(string.match(progress, "%d+"))

            if p ~= nil then
              local index = math.floor(p / (100 / #spinners)) + 1
              return "  " .. spinners[index]
            end
          end,
          separator = { left = icons[separator_style].left },
          -- cond = hide_in_width,
        },
        {
          "location",
          -- cond = hide_in_width,
        },
      })

      ins_config("z", {
        {
          function()
            local msg = "No Active Lsp"
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local clients = vim.lsp.get_clients()
            if next(clients) == nil then
              return msg
            end
            for _, client in ipairs(clients) do
              local filetypes = client.config.filetypes
              if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                if client.name ~= "null-ls" then
                  return client.name
                end
              end
            end
            return msg
          end,
        },
        {
          function()
            return " " .. os.date("%R")
          end,
        },
      })

      require("lualine").setup({
        options = {
          theme = custom_theme,
          component_separators = "",
          section_separators = { left = icons[separator_style].right, right = icons[separator_style].left },
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter", "NvimTree", "lazy", "neo-tree" } },
          -- refresh = {
          --   statusline = 1000,
          -- },
        },
        sections = sections,
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
        -- winbar = {
        --   lualine_a = { "buffers" },
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = { "tabs" },
        -- },
        -- inactive_winbar = {
        --   lualine_a = { "buffers" },
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = { "tabs" },
        -- },
        extensions = {},
      })
    end,
  },
 {
    "RRethy/vim-illuminate",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
      -- signs = {
      --   add = { text = "▎" },
      --   change = { text = "▎" },
      --   delete = { text = "" },
      --   topdelete = { text = "" },
      --   changedelete = { text = "▎" },
      --   untracked = { text = "▎" },
      -- },
}
