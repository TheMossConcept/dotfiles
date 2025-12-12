return {
  "rcarriga/nvim-dap-ui",
  dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio", "folke/lazydev.nvim"},
  keys = {
    { "<leader>tb", ":DapToggleBreakpoint<CR>" },
    { "<leader>dc", ":DapContinue<CR>" },
    { "<leader>so", ":DapStepOver<CR>" },
    { "<leader>si", ":DapStepInto<CR>" }
  },
  config = function ()
    local dap, dapui = require("dap"), require("dapui")

    dapui.setup()

   require("lazydev").setup({
      library = { "nvim-dap-ui" },
    })
    -- Set up node adapter
    dap.adapters["pwa-node"] = {
      type = 'server',
      host = 'localhost',
      port = '9229',
      executable = {
        command = 'js-debug-adapter',
        args = {
          '9229',
        },
      },
    }

    dap.configurations["typescript"] = {
      {
        type = 'pwa-node',
        request = 'attach',
        processId = require('dap.utils').pick_process,
        name = 'Attach to node',
        cwd = "${workspaceFolder}",
        -- sourceMaps = true,
        -- program = '${workspaceFolder}/backend/src/app.ts',
      }
    }

    dap.configurations["javascript"] = {
      {
        type = 'pwa-node',
        request = 'attach',
        processId = require('dap.utils').pick_process,
        name = 'Attach to node',
        cwd = "${workspaceFolder}",
        -- program = '${workspaceFolder}/backend/src/app.ts',
      }
    }

    -- Add event listeners to automatically start dapui when a dap session starts
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end

    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end
}
