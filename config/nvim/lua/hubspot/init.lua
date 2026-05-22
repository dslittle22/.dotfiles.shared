local M = {}

function M.is_hubspot()
  return vim.env.USER == "dalittle"
end

if M.is_hubspot() then
  require("hubspot.packhooks")
end

return M
