local M = {}

function M.new(fn)
  local out = {}
  out.__index = out

  local mt = {
    __call = function(cls, ...)
      return cls.new(...)
    end,
  }

  setmetatable(out, mt)

  function out.new(...)
    local self = setmetatable({}, out)
    fn(self, ...)
    return self
  end

  return out
end

return M
