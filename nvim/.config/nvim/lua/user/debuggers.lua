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

nnoremap("<leader>dc", function()
  dap.continue()
end);

nnoremap("<leader>db", function()
  dap.toggle_breakpoint()
end);

nnoremap("<leader>dss", function()
  dap.step_over()
end);

nnoremap("<leader>dsi", function()
  dap.step_into()
end);

nnoremap("<leader>dso", function()
  dap.step_out()
end);

nnoremap("<leader>drc", function()
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
}

daptext.setup()
dapui.setup({

})
