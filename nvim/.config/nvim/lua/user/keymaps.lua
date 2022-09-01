M = {}
local function nnoremap(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { noremap = true })
end

M.nnoremap = nnoremap

return M
