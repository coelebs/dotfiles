M = {}
local function nnoremap(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { noremap = true })
end

local function vnoremap(lhs, rhs)
    vim.keymap.set("v", lhs, rhs, { noremap = true })
end

M.nnoremap = nnoremap
M.vnoremap = vnoremap

return M
