local source = {}
local M = {}

local cache = {}
local lookup = {}

local TRANSLATION_COMPONENTS = {
  FormattedMessage = true,
  FormattedHTMLMessage = true,
  FormattedJSXMessage = true,
  FormattedReactMessage = true,
}

local I18N_METHODS = {
  text = true,
  unescapedText = true,
}

local function is_translation_context(bufnr, row, col)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
  if not ok or not node then return false end

  local current = node
  while current do
    local t = current:type()

    if t == "call_expression" then
      local func = current:named_child(0)
      if not func then return false end
      local name = vim.treesitter.get_node_text(func, bufnr)
      return I18N_METHODS[name] == true
        or I18N_METHODS[name:match("%.(%w+)$") or ""] == true
    end

    if t == "jsx_self_closing_element" or t == "jsx_opening_element" then
      local tag = current:named_child(0)
      if tag then return TRANSLATION_COMPONENTS[vim.treesitter.get_node_text(tag, bufnr)] == true end
      return false
    end

    current = current:parent()
  end
  return false
end

local function get_translation_key_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
  if not ok or not node then return nil end

  if node:type() ~= "string_fragment" then return nil end
  if not is_translation_context(bufnr, row, col) then return nil end

  return vim.treesitter.get_node_text(node, bufnr)
end

local function find_git_root(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then return nil end

  local dir = vim.fn.fnamemodify(filepath, ":h")
  while dir ~= "/" do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

local function flatten_yaml(lines)
  local results = {}
  local stack = {}
  local lnum = 0

  for _, line in ipairs(lines) do
    lnum = lnum + 1

    if line:match("^%s*#") or line:match("^%s*$") then
      goto continue
    end

    local indent = #(line:match("^(%s*)") or "")
    local key, value = line:match("^%s*([%w_%.%-]+):%s+(.+)$")

    if not key then
      key = line:match("^%s*([%w_%.%-]+):%s*$")
    end

    if key then
      while #stack > 0 and stack[#stack].indent >= indent do
        table.remove(stack)
      end

      if value and value ~= "" then
        local parts = {}
        for _, entry in ipairs(stack) do
          table.insert(parts, entry.key)
        end
        table.insert(parts, key)
        local full_key = table.concat(parts, ".")
        value = value:gsub("^[\"'](.+)[\"']$", "%1")
        results[full_key] = { value = value, lnum = lnum }
      else
        table.insert(stack, { key = key, indent = indent })
      end
    end

    ::continue::
  end

  return results
end

local function parse_lyaml_files(file_paths)
  local items = {}
  local lookup_table = {}

  for _, path in ipairs(file_paths) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local lines = {}
      for line in content:gmatch("([^\r\n]*)[\r\n]?") do
        table.insert(lines, line)
      end
      local entries = flatten_yaml(lines)
      for k, entry in pairs(entries) do
        local key = k:gsub("^en%.", "")
        lookup_table[key] = { value = entry.value, file = path, lnum = entry.lnum }
      end
    end
  end

  for key, entry in pairs(lookup_table) do
    table.insert(items, {
      label = key,
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      documentation = {
        kind = "markdown",
        value = entry.value,
      },
    })
  end

  table.sort(items, function(a, b) return a.label < b.label end)
  return items, lookup_table
end

local EMPTY = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }

local function ensure_cache(root, callback)
  if cache[root] then
    callback()
    return
  end

  vim.system(
    { "rg", "--files", "-g", "*en.lyaml", root },
    { text = true },
    function(result)
      if result.code ~= 0 or result.stdout == "" then
        vim.schedule(callback)
        return
      end

      local lyaml_files = vim.split(result.stdout, "\n", { trimempty = true })
      local items, lookup_table = parse_lyaml_files(lyaml_files)
      cache[root] = items
      lookup[root] = lookup_table
      vim.schedule(callback)
    end
  )
end

-- blink-cmp source interface

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  return self
end

function source:get_trigger_characters()
  return { '"', "'" }
end

function source:get_completions(ctx, callback)
  callback = vim.schedule_wrap(callback)

  local bufnr = ctx.bufnr
  local row = ctx.cursor[1] - 1
  local col = ctx.cursor[2]

  if not is_translation_context(bufnr, row, col) then
    callback(EMPTY)
    return
  end
  local root = find_git_root(bufnr)

  if not root then
    callback(EMPTY)
    return
  end

  if cache[root] then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = cache[root] })
    return
  end

  ensure_cache(root, function()
    if cache[root] then
      callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = cache[root] })
    else
      callback(EMPTY)
    end
  end)
end

-- hover and go-to-definition

local function translation_hover()
  local key = get_translation_key_at_cursor()
  if not key then
    vim.lsp.buf.hover()
    return
  end

  local root = find_git_root(vim.api.nvim_get_current_buf())
  if not root then
    vim.lsp.buf.hover()
    return
  end

  local function show()
    local entry = lookup[root] and lookup[root][key]
    if entry then
      vim.lsp.util.open_floating_preview(
        { entry.value, "", "`" .. key .. "`" },
        "markdown",
        { focus_id = "hs_translation_hover" }
      )
    else
      vim.notify("Translation key not found: " .. key, vim.log.levels.WARN)
    end
  end

  if lookup[root] then
    show()
  else
    ensure_cache(root, show)
  end
end

local function translation_goto_definition()
  local key = get_translation_key_at_cursor()
  if not key then
    vim.lsp.buf.definition()
    return
  end

  local root = find_git_root(vim.api.nvim_get_current_buf())
  if not root then
    vim.lsp.buf.definition()
    return
  end

  local function jump()
    local entry = lookup[root] and lookup[root][key]
    if entry then
      vim.cmd.edit(entry.file)
      vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
    else
      vim.notify("Translation key not found: " .. key, vim.log.levels.WARN)
    end
  end

  if lookup[root] then
    jump()
  else
    ensure_cache(root, jump)
  end
end

function M.setup()
  local js_fts = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true }
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      if not js_fts[vim.bo[args.buf].filetype] then return end
      local opts = { buffer = args.buf }
      vim.keymap.set("n", "K", translation_hover, opts)
      vim.keymap.set("n", "gd", translation_goto_definition, opts)
    end,
  })
end

-- Export both the blink source (default) and setup
M.new = source.new
M.get_trigger_characters = source.get_trigger_characters
M.get_completions = source.get_completions

return M
