--[[lit-meta
  name = "creationix/mutex-wrapper"
  version = "0.1.0"
  homepage = "https://github.com/creationix/lua-postgres/blob/master/mutex-wrapper.lua"
  description = "A function wrapper that only lets one instance run at a time."
  tags = {"coro", "mutex"}
  dependencies = {
    "creationix/defer-resume@0.1.0"
  }
  license = "MIT"
  contributors = {
    "Tim Caswell",
  }
]]

local deferResume = require 'creationix/defer-resume'

-- Create a new shared mutex
return function ()
    local queue = {}
    local n = 1
    -- Wrap a function and add it to the set of functions that can only run one at a time.
    return function (fn)
        return function(...)
            local i
            if queue[n] then
                n = n + 1
                i = n
                queue[i] = coroutine.running()
                coroutine.yield(...)
            else
                i = n
                queue[i] = true
            end
            local ret = {fn(...)}
            queue[i] = nil
            local waiter = queue[i + 1]
            if waiter then
                deferResume(waiter)
            end
            return unpack(ret)
        end
    end
end
