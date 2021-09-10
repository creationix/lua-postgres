--[[lit-meta
  name = "creationix/defer-resume"
  version = "0.1.0"
  homepage = "https://github.com/creationix/lua-postgres/blob/master/defer-resume.lua"
  description = "A helper to resume a coroutine on a later stack."
  tags = {"coro"}
  license = "MIT"
  contributors = {
    "Tim Caswell",
  }
]]

local uv = require 'uv'

local checker = uv.new_check()
local idler = uv.new_idle()
local immediateQueue = {}

local function onCheck()
  local queue = immediateQueue
  immediateQueue = {}
  for i = 1, #queue do
    local success, err = coroutine.resume(queue[i])
    if not success then
        print("Uncaught error in defer-resume coroutine: " .. err)
    end
  end
  if #immediateQueue == 0 then
    uv.check_stop(checker)
    uv.idle_stop(idler)
  end
end

-- Given a coroutine, resume it on it's own top-level event loop stack.
return function (co)

  -- If the queue was empty, the check hooks were disabled.
  -- Turn them back on.
  if #immediateQueue == 0 then
    uv.check_start(checker, onCheck)
    uv.idle_start(idler, onCheck)
  end

  immediateQueue[#immediateQueue + 1] = co
end
