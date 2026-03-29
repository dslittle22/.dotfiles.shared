local source = {}

local cache = {}

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

local function get_node_text(node, bufnr)
  return vim.treesitter.get_node_text(node, bufnr)
end

local function find_ancestor(node, type)
  local current = node
  while current do
    if current:type() == type then return current end
    current = current:parent()
  end
  return nil
end

local function is_jsx_translation_context(node, bufnr)
  -- Walk up to find jsx_attribute
  local attr = find_ancestor(node, "jsx_attribute")
  if not attr then return false end

  -- Check the attribute name is "message"
  local attr_name = attr:named_child(0)
  if not attr_name or get_node_text(attr_name, bufnr) ~= "message" then
    return false
  end

  -- Walk up to jsx_self_closing_element or jsx_opening_element
  local element = attr:parent()
  if not element then return false end
  local element_type = element:type()
  if element_type ~= "jsx_self_closing_element" and element_type ~= "jsx_opening_element" then
    return false
  end

  -- Check the tag name
  local tag = element:named_child(0)
  if not tag then return false end
  local tag_name = get_node_text(tag, bufnr)
  return TRANSLATION_COMPONENTS[tag_name] == true
end

local function is_i18n_call_context(node, bufnr)
  -- Walk up to find arguments node
  local args = find_ancestor(node, "arguments")
  if not args then return false end

  -- Check we're in the first argument position
  local string_node = find_ancestor(node, "string") or find_ancestor(node, "template_string")
  if not string_node then return false end
  local first_arg = args:named_child(0)
  if not first_arg or first_arg:id() ~= string_node:id() then return false end

  -- Parent should be call_expression
  local call = args:parent()
  if not call or call:type() ~= "call_expression" then return false end

  -- The function should be a member_expression like I18n.text
  local func = call:named_child(0)
  if not func or func:type() ~= "member_expression" then return false end

  local object = func:named_child(0)
  local property = func:named_child(1)
  if not object or not property then return false end

  return get_node_text(object, bufnr) == "I18n" and I18N_METHODS[get_node_text(property, bufnr)] == true
end

local function is_translation_context(bufnr, row, col)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
  if not ok or not node then return false end
  return is_jsx_translation_context(node, bufnr) or is_i18n_call_context(node, bufnr)
end

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  return self
end

function source:get_trigger_characters()
  return { '"', "'" }
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

  for _, line in ipairs(lines) do
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
        results[full_key] = value
      else
        table.insert(stack, { key = key, indent = indent })
      end
    end

    ::continue::
  end

  return results
end

local function parse_lyaml_files(file_paths)
  local merged = {}

  for _, path in ipairs(file_paths) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local lines = {}
      for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
      end
      local entries = flatten_yaml(lines)
      for k, v in pairs(entries) do
        merged[k] = v
      end
    end
  end

  local items = {}
  for key, value in pairs(merged) do
    key = key:gsub("^en%.", "")
    table.insert(items, {
      label = key,
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      documentation = {
        kind = "markdown",
        value = value,
      },
    })
  end

  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

local EMPTY = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }

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

  vim.system(
    { "rg", "--files", "-g", "*en.lyaml", root },
    { text = true },
    function(result)
      if result.code ~= 0 or result.stdout == "" then
        callback(EMPTY)
        return
      end

      local lyaml_files = vim.split(result.stdout, "\n", { trimempty = true })
      local items = parse_lyaml_files(lyaml_files)
      cache[root] = items
      callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
    end
  )
end

return source
