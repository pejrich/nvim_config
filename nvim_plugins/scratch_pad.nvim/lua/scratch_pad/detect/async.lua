-- using JavaScript Promise's analogy
local co = coroutine

local M = {}

local function await_fn(value)
  return co.yield(value)
end

local function process_async(async_generator, resolve)
  vim.validate({
    async_generator = { async_generator, "c" },
    resolve = { resolve, "c", true },
  })
  local thread = co.create(async_generator)
  local function process(last_value)
    local _, value = co.resume(thread, last_value)
    local done = co.status(thread) == "dead"

    if done then
      -- async return raw value
      return (resolve or function() end)(value)
    else
      -- async yield promise
      if type(value) == "function" then
        return value(process)
      else
        return M.resolve(value)(process)
      end
    end
  end

  return process(await_fn)
end

M.resolve = function(value)
  return function(resolve)
    return resolve(value)
  end
end

M.promise = setmetatable({
  all = function(promises)
    vim.validate({
      promises = { promises, "t" },
    })
    local count = vim.tbl_count(promises)
    local values = {}
    local done = 0

    return function(resolve)
      if vim.tbl_isempty(promises) then
        return resolve()
      end

      for index, promise in ipairs(promises) do
        promise(function(value)
          values[index] = value
          done = done + 1

          if done == count then
            return resolve(values)
          end
        end)
      end
    end
  end,
}, {
  __call = function(_, async_fn)
    vim.validate({
      async_fn = { async_fn, "c" },
    })
    return M.async(function(await)
      return await(async_fn)
    end)
  end,
})

M.async = function(async_generator)
  vim.validate({
    async_generator = { async_generator, "c" },
  })
  return function(resolve)
    return process_async(async_generator, resolve)
  end
end

return M
