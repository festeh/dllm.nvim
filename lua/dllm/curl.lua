local uv = vim.uv


--- @class Curl
Curl = {}

--- @class CurlParams
--- @field url string
--- @field body string
--- @field on_start function
--- @field on_stdout_event function
--- @field on_stderr_event function
--- @field on_exit function

--- @param params CurlParams
function Curl.request(config, params)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local args = {
    "--no-progress-meter",
    "-N",
    "-H",
    "Content-Type: application/json",
    "-X",
    "POST",
    "-d",
    params.body,
    params.url,
  }


  if params.on_start then
    params.on_start()
  end

  local on_exit = params.on_exit or function(...) end
  local proc_handle = uv.spawn("curl", { args = args, stdio = { nil, stdout, stderr }, detached = true}, on_exit)

  if params.on_stdout_event then
    uv.read_start(stdout, function(err, data)
      if data then
        params.on_stdout_event(data)
      else
        vim.notify("error while reading stdout", err)
      end
    end)
  end

  if params.on_stderr_event then
    uv.read_start(stderr, function(err, data)
      if data then
        params.on_stderr_event(data)
      else
        vim.notify("error while reading stderr", err)
      end
    end)
  end

  return proc_handle
end

return Curl
