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

dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode-10', -- adjust as needed, must be absolute path
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.loop.cwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = {},
    },
    {
        name = "Remote attach",
        type = "lldb",
        request = "custom",
        targetCreateCommands = {"target create ${workspaceFolder}/devices/main/update/update"},
        processCreateCommands = {"gdb-remote 192.168.137.230:1234"},
    },
}

daptext.setup()
dapui.setup({

})
