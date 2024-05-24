local locations_to_items = vim.lsp.util.locations_to_items
vim.lsp.util.locations_to_items = function (locations, offset_encoding)
  local lines = {}
  local loc_i = 1
  for _, loc in ipairs(vim.deepcopy(locations)) do
    local uri = loc.uri or loc.targetUri
    local range = loc.range or loc.targetSelectionRange
    if lines[uri .. range.start.line] then -- already have a location on this line
      table.remove(locations, loc_i) -- remove from the original list
    else
      loc_i = loc_i + 1
    end
    lines[uri .. range.start.line] = true
  end

  return locations_to_items(locations, offset_encoding)
end
