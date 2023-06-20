local dapok, dap = pcall(require, 'dap')
if not dapok then
  vim.notify("dap not installed")
end

local ok, daptext = pcall(require, "nvim-dap-virtual-text")
if not ok then
  vim.notify("daptext not installed")
end

local uiok, dapui = pcall(require, 'dapui')
if not dapok then
  vim.notify("dapui not installed")
end

local nnoremap = require("user.keymaps").nnoremap
vim.g.mapleader = " "

nnoremap("<F6>", function()
  dapui.toggle()
end);

nnoremap("<F7>", function()
  dap.toggle_breakpoint()
end);

nnoremap("<F8>", function()
  dap.continue()
end);

nnoremap("<F9>", function()
  dap.step_over()
end);

nnoremap("<F10>", function()
  dap.step_into()
end);

nnoremap("<F11>", function()
  dap.step_out()
end);

nnoremap("<F12>", function()
  dap.run_to_cursor()
end);

dap.adapters.cppdbg = {
    type = 'executable',
    command = '/home/vin/local/tools/extension/debugAdapters/bin/OpenDebugAD7',
    name = 'cppdbg'
}

dap.adapters.cdbg = {
    type = 'executable',
    command = '/home/vin/local/tools/extension/debugAdapters/bin/OpenDebugAD7',
    name = 'cdbg'
}

dap.configurations.c = {
  {
    name = "Debug J-Link",
    type = "cdbg",
    request = "launch",
    cwd = "/home/vin/projects/emb4/EMB-23-Update-the-motor/main/",
    program = "/home/vin/projects/emb4/EMB-23-Update-the-motor/build/zephyr/zephyr.elf",
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

daptext.setup()
dapui.setup({

})

