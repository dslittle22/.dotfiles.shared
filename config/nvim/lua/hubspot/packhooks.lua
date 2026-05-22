local group = vim.api.nvim_create_augroup("HubSpotPackHooks", { clear = true })

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    if ev.data.spec.name ~= "neotest-hs-jasmine" then
      return
    end

    if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
      return
    end

    local result = vim.system({ "bend", "yarn" }, { cwd = ev.data.path .. "/runner", text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr ~= "" and result.stderr or result.stdout, vim.log.levels.ERROR)
    end
  end,
})
