return {
  "mfussenegger/nvim-dap",
  dependencies = {"rcarriga/nvim-dap-ui", "theHamsta/nvim-dap-virtual-text"},
  keys = {
    {"<F6>", function() require("dapui").toggle() end},
    {"<F7>", function() require("dap").toggle_breakpoint() end},
    {"<F8>", function() require("dap").continue() end},
    {"<F9>", function() require("dap").step_over() end},
    {"<F10>", function() require("dap").step_into() end},
    {"<F11>", function() require("dap").step_out() end},
    {"<F12>", function() require("dap").run_to_cursor() end},
    {"<Leader>dbc", function() require("dap").run_to_cursor() end},
  },
  config = function()
    require("dap").adapters.cppdbg = {
      type = 'executable',
      command = '/home/vin/local/tools/extension/debugAdapters/bin/OpenDebugAD7',
      name = 'cppdbg'
    }

    require("dap").adapters.cdbg = {
      type = 'executable',
      command = '/home/vin/local/tools/extension/debugAdapters/bin/OpenDebugAD7',
      name = 'cdbg'
    }

    require("dap").configurations.c = {
      {
        name = "Debug J-Link",
        type = "cdbg",
        request = "launch",
        cwd = "${workspaceFolder}",
        program = "${workspaceFolder}/build/zephyr/zephyr.elf",
        stopAtEntry = false,
        MIMode = "gdb",
        miDebuggerServerAddress = "localhost:2331",
        miDebuggerPath = "/opt/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gdb",
        serverLaunchTimeout = 5000,
        postRemoteConnectCommands = {
          {
            text = "monitor reset",
            ignoreFailures = false
          },
          {
            text = "load",
            ignoreFailures = false
          },
        },
      }
    }

    require("nvim-dap-virtual-text").setup()
    require("dapui").setup()
  end
}
