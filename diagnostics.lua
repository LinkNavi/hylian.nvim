-- Diagnostic config — no plugin dependency needed, runs at startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- ── Signs ────────────────────────────────────────────────────────────────
    local signs = {
      [vim.diagnostic.severity.ERROR] = { text = " ", hl = "DiagnosticSignError" },
      [vim.diagnostic.severity.WARN]  = { text = " ", hl = "DiagnosticSignWarn"  },
      [vim.diagnostic.severity.INFO]  = { text = " ", hl = "DiagnosticSignInfo"  },
      [vim.diagnostic.severity.HINT]  = { text = "󰌵 ", hl = "DiagnosticSignHint"  },
    }

    for _, sign in pairs(signs) do
      vim.fn.sign_define(sign.hl, {
        text   = sign.text,
        texthl = sign.hl,
        numhl  = sign.hl,
      })
    end

    -- ── Core config ──────────────────────────────────────────────────────────
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        prefix  = function(diagnostic)
          return signs[diagnostic.severity].text
        end,
        format = function(diagnostic)
          return diagnostic.message
        end,
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style     = "minimal",
        border    = "rounded",
        source    = false,
        header    = "",
        prefix    = "",
        format    = function(diagnostic)
          local icon = signs[diagnostic.severity].text
          local src  = diagnostic.source and ("[" .. diagnostic.source .. "] ") or ""
          return icon .. src .. diagnostic.message
        end,
      },
    })

    -- ── Auto float on CursorHold ─────────────────────────────────────────────
    vim.api.nvim_create_autocmd("CursorHold", {
      callback = function()
        vim.diagnostic.open_float(nil, {
          focusable    = true,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border       = "rounded",
          source       = false,
          prefix       = "",
          format       = function(diagnostic)
            local icon = signs[diagnostic.severity].text
            local src  = diagnostic.source and ("[" .. diagnostic.source .. "] ") or ""
            return icon .. src .. diagnostic.message
          end,
          scope = "cursor",
        })
      end,
    })

    -- ── Keymaps ──────────────────────────────────────────────────────────────
    vim.keymap.set("n", "<C-S-d>", function()
      vim.diagnostic.goto_next({ float = false })
    end, { desc = "Next diagnostic" })

    vim.keymap.set("n", "<C-S-f>", function()
      vim.diagnostic.goto_prev({ float = false })
    end, { desc = "Previous diagnostic" })

    vim.keymap.set("n", "<leader>e", function()
      vim.diagnostic.open_float()
    end, { desc = "Show diagnostic float" })
  end,
})

return {}
