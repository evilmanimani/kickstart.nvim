-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information


-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   pattern = { "*.js", "*.ts" },
--   command = "EslintFixAll"
-- })
-- vim.g.neovide_transparency = 0.95
-- vim.g.neovide_scale_factor = 0.95
-- vim.g.neovide_cursor_animate_command_line = false
-- vim.g.neovide_fullscreen = true
-- vim.g.neovide_cursor_vfx_mode = ""
-- vim.g.neovide_cursor_trail_size = 0.25
vim.o.guifont = "FiraCode Nerd Font:h12"
vim.o.shell = "zsh"
vim.g.miniindentscope_disable = true
vim.o.relativenumber = true

---- below isn't needed because of sleuth
-- vim.o.softtabstop = 2
-- vim.o.shiftwidth = 2
-- vim.opt.signcolumn = "number"

local vk = vim.keymap.set

-- if vim.g.neovide then
--   local change_scale_factor = function(delta)
--     vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
--     vim.cmd("redraw!")
--   end
--   vk("n", "<C-=>", function()
--     change_scale_factor(1.11)
--   end)
--   vk("n", "<C-->", function()
--     change_scale_factor(1 / 1.11)
--   end)
--   vk("n", "<F11>", function()
--     vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
--   end, { desc = "Toggle fullscreen" })
-- end


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
-- vim.api.nvim_set_keymap("", "<C-v>", "+p<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

vk("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "find files" })
-- vk("n", "<C-A-o>", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Find symbols" })
vk("i", "jj", "<esc>", { desc = "<ESC>" })
vk(
  "n",
  "<leader>e",
  "<cmd>lua require('mini.files').open(vim.api.nvim_buf_get_name(0), false)<cr>",
  { desc = "[e]xplore mini.files" }
)
-- vk("n", "<C-a>", "za", { desc = "Toggle fold" })

-- split lines at next ';', ',' or space
vk('n', '<C-j>',
  function()
    local chars = { ';', ',', ' ' }
    local api = vim.api
    local cPos = api.nvim_win_get_cursor(0)
    local row = cPos[1]
    local col = cPos[2]
    local line = api.nvim_get_current_line() -- returns focused line
    local indent = line:match('^(%s+)') or ''

    local function splitLine(idx)
      local lineStart = line:sub(1, idx)
      local newLine = indent .. string.gsub(line:sub(idx + 1), '^%s+', '')
      if newLine:match('^%s+$') then newLine = '' end
      if lineStart:match('^%s+$') then lineStart = '' end
      api.nvim_set_current_line(lineStart)
      api.nvim_buf_set_lines(0, row, row, false, { newLine })
      api.nvim_win_set_cursor(0, { row + 1, indent:len() or 0 })
    end

    local match = 0
    for _, char in ipairs(chars) do
      match = line:find(char, col + 1) or 0
      if match > 0 then
        splitLine(match)
        return
      end
    end

    print(tostring(match))
    if match == 0 then
      splitLine(col)
    end
  end,
  { desc = "split line (at space)" })

local function arraySome(array, callback)
  for _, value in ipairs(array) do
    if callback(value) then
      return true
    end
  end
  return false
end

local function matchJS()
  return arraySome({ 'javascript', 'typescript' }, function(t)
    return t == vim.bo.filetype
  end)
end

vk("n", "<leader>pj", "<cmd>pu<cr>", { desc = "pastebelow" })
vk("n", "<leader>pk", "<cmd>pu!<cr>", { desc = "paste above" })
vk("n", "<leader>pp", "$p", { desc = "paste at end of line" })
vk("n", "<leader>?", "<cmd>Telescope oldfiles<cr>", { desc = "recent files" })
-- vk("n", "<leader>s?", "<cmd>Cheatsheet<cr>", { desc = "cheatsheet" })
vk("n", "<leader>m", "<cmd>messages<cr>", { desc = "show [m]essages" })
vk("v", "<F2>", "<cmd>'<,'>w !node<cr>", { expr = matchJS(), desc = "execute selection in node" })
vk("n", "<F2>", "<cmd>w !node<cr>", { expr = matchJS(), desc = "execute buffer in node" })
local liveServerStarted = false
vk("n", "<F10>", function()
    if liveServerStarted then vim.cmd('KillLiveServerOnPort 3000') else vim.cmd('StartLiveServer') end
    liveServerStarted = not liveServerStarted
  end,
  { desc = "toggle live-server" })
-- vk("n", "<F9>", "<cmd>LiveServerStop<cr>", { desc = "stop live-server" })
vk("n", "<C-d>", "<C-d>zz")
vk("n", "<C-u>", "<C-u>zz")
vk("x", "<leader>p", [["_dP]])
vk("n", "<leader>-", "<C-W>s", { desc = "split window below", remap = true })
vk("n", "<leader>|", "<C-W>v", { desc = "split window right", remap = true })
vk("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "[l]azy" })
-- Clear search with <esc>
vk({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "escape and clear hlsearch" })
-- buffers
vk("n", "<leader>`", "<cmd>e #<cr>", { desc = "switch to other buffer" })
-- vk("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "prev buffer" })
-- vk("n", "<S-l>", "<cmd>bnext<cr>", { desc = "next buffer" })
vk("n", "[b", "<cmd>bprevious<cr>", { desc = "prev buffer" })
vk("n", "]b", "<cmd>bnext<cr>", { desc = "next buffer" })
-- better up/down
vk({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vk({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vk({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vk({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- Move to window using the <ctrl> hjkl keys
vk("n", "<C-M-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vk("n", "<C-M-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vk("n", "<C-M-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vk("n", "<C-M-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vk("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vk("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vk("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vk("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

require('which-key').register {
  ['<leader>b'] = { name = '[b]uffer', _ = 'which_key_ignore' },
  ['<leader>p'] = { name = '[p]aste', _ = 'which_key_ignore' },
}

-- options for vim.diagnostic.config()
vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  update_in_insert = false,
  severity_sort = false,
  signs = true,
})

for type, icon in pairs(Ilazy.diagnostics) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

return {
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  -- { "lukas-reineke/lsp-format.nvim" },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>p"] = { name = "+paste" },
      },
    }
  },
  { 'wolandark/vim-live-server' },
  {
    'numToStr/FTerm.nvim',
    init = function()
      vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>')
      vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    end
  },
  -- {
  --   'turbio/bracey.vim'
  -- },
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add any options here
  --   },
  --   dependencies = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   }
  -- },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          jump_labels = true,
        }
      }
    },
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    init = function()
      require("mini.ai").setup()
      -- local ai = require("mini.ai")
      -- ai.setup({
      --   n_lines = 500,
      --   custom_textobjects = {
      --     o = ai.gen_spec.treesitter({
      --       a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      --       i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      --     }, {}),
      --     f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
      --     c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
      --     t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
      --   },
      -- })
      require("mini.files").setup()
      -- require("mini.notify").setup({})
      if UseTabline then
        require("mini.tabline").setup()
      end
      require("mini.pairs").setup()
      require("mini.surround").setup({
        mappings = {
          add = "gsa",            -- Add surrounding in Normal and Visual modes
          delete = "gsd",         -- Delete surrounding
          find = "gsf",           -- Find surrounding (to the right)
          find_left = "gsF",      -- Find surrounding (to the left)
          highlight = "gsh",      -- Highlight surrounding
          replace = "gsr",        -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      })
      require("mini.splitjoin").setup()
      require("mini.align").setup()
      require("mini.bracketed").setup()
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
      end, { desc = "Delete Buffer" })
      vk("n", "<leader>bD", function() require("mini.bufremove").delete(0, true) end, { desc = "Delete Buffer (Force)" })
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
    "RRethy/vim-illuminate",
    lazy = false,
    opts = {
      delay = 100,
      -- large_file_cutoff = 2000,
      -- large_file_overrides = {
      --   providers = { "treesitter", "lsp" },
      -- },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      -- change the highlight style
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })

      --- auto update the highlight style on colorscheme change
      vim.api.nvim_create_autocmd({ "ColorScheme" }, {
        pattern = { "*" },
        callback = function(ev)
          vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
          vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
          vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
        end
      })

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("<c-]>", "next")
      map("<c-[>", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("<c-]>", "next", buffer)
          map("<c-[>", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "<c-]>", desc = "Next Reference" },
      { "<c-[>", desc = "Prev Reference" },
    },
  },
  -- Finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "todo (trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "todo/fix/fixme (trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "[s]earch [t]odo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "[s]earch labels=[T]odo/fix/fixme" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local separator_style = "default"
      local solarized_palette = require("solarized.palette")
      local colors = solarized_palette.get_colors()

      local custom_theme = {
        normal = {
          a = { fg = colors.base03, bg = colors.blue },
          b = { fg = colors.base02, bg = colors.base01 },
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
          a = { fg = colors.base02, bg = colors.base01 },
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
        diff = { added = Ilazy.git.added, modified = Ilazy.git.modified, removed = Ilazy.git.removed },
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
          cond = hide_in_width,
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
          cond = hide_in_width,
        },
      })

      local function fg(name)
        ---@type {foreground?:number}?
        ---@diagnostic disable-next-line: deprecated
        local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or
            vim.api.nvim_get_hl_by_name(name, true)
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
          cond = hide_in_width,
        },
        {
          "location",
          cond = hide_in_width,
        },
      })

      ins_config("z", {
        {
          function()
            local msg = "No Active Lsp"
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local clients = vim.lsp.get_active_clients()
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
      local config = {
        options = {
          -- theme = 'NeoSolarized', -- custom_theme,
          theme = custom_theme,
          -- theme = "catppuccin",
          component_separators = "",
          section_separators = { left = icons[separator_style].right, right = icons[separator_style].left },
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter", "NvimTree", "lazy", "neo-tree" } },
          refresh = {
            statusline = 1000,
          },
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
        extensions = {},
      }

      if not UseTabline then
        config.winbar = {
          lualine_a = { "buffers" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "tabs" },
        }
        -- config.inactive_winbar = {
        --   lualine_a = { "buffers" },
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = { "tabs" },
        -- },
      end

      require("lualine").setup(config)

      local function copyHl(from, to, prop, remap, invert)
        local hl = vim.api.nvim_get_hl(0, { name = from })
        if prop then
          if remap then
            local hl2 = vim.api.nvim_get_hl(0, { name = to })
            hl2[remap] = hl[prop]
            if invert then hl2[prop] = hl[remap] end
            if hl2.link then hl2.link = '' end
            hl = hl2
          else
            hl = { [prop] = hl[prop] }
          end
          -- print(vim.inspect(hl) .. ' | ' .. remap)
        end
        vim.api.nvim_set_hl(0, to, hl)
      end

      -- recolor MiniTabline
      copyHl('lualine_a_normal', 'MiniTablineCurrent')
      copyHl('lualine_a_normal', 'MiniTablineVisible', 'bg', 'fg', true)
      copyHl('lualine_a_insert', 'MiniTablineModifiedCurrent')
      copyHl('lualine_a_insert', 'MiniTablineModifiedVisible', 'bg', 'fg', true)
      copyHl('lualine_a_insert', 'MiniTablineModifiedHidden', 'bg', 'fg', true)
    end,
  },
  {
    'glacambre/firenvim',

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end
  },
  -- signs = {
  --   add = { text = "▎" },
  --   change = { text = "▎" },
  --   delete = { text = "" },
  --   topdelete = { text = "" },
  --   changedelete = { text = "▎" },
  -- },
}
