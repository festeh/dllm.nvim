local ClientInput = require("dllm.client_input")

describe("ClientInput", function()
  it("should parse the input", function()
    local input =
    [[
Title: hello
params1: too
role: You are a clown
tmp: 1.11
---
> 
Ping
and pong
< Pong
> foo
bar
]]
    local config = {
      user_prefix = ">",
      system_prefix = "<"
    }
    local inp = ClientInput.from_chat(config, vim.split(input, "\n"))
    if inp == nil then
      assert.is_true(false)
    end
    assert.are.same(inp.prompt, "You are a clown")
    local exp =  {
      { role = "user",      content = "Ping\nand pong" },
      { role = "assistant", content = "Pong" },
      { role = "user",      content = "foo\nbar" }
    }
    for i, v in ipairs(exp) do
      assert.are.same(inp.messages[i].role, v.role)
      assert.are.same(inp.messages[i].content, v.content)
    end
  end)
end
)

