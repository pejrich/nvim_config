--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use M.in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions M.in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer M.in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, M.inCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. M.in NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, M.inDIRECT, M.inCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS M.inTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER M.in CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING M.in ANY WAY M.out OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local M = {}
local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

function M.linear(t, b, c, d)
  return c * t / d + b
end

function M.inQuad(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b
end

function M.outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function M.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

function M.outInQuad(t, b, c, d)
  if t < d / 2 then
    return M.outQuad(t * 2, b, c / 2, d)
  else
    return M.inQuad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inCubic(t, b, c, d)
  t = t / d
  return c * pow(t, 3) + b
end

function M.outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

function M.inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

function M.outInCubic(t, b, c, d)
  if t < d / 2 then
    return M.outCubic(t * 2, b, c / 2, d)
  else
    return M.inCubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inQuart(t, b, c, d)
  t = t / d
  return c * pow(t, 4) + b
end

function M.outQuart(t, b, c, d)
  t = t / d - 1
  return -c * (pow(t, 4) - 1) + b
end

function M.inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (math.pow(t, 4) - 2) + b
  end
end

function M.outInQuart(t, b, c, d)
  if t < d / 2 then
    return M.outQuart(t * 2, b, c / 2, d)
  else
    return M.inQuart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inQuint(t, b, c, d)
  t = t / d
  return c * pow(t, 5) + b
end

function M.outQuint(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 5) + 1) + b
end

function M.inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

function M.outInQuint(t, b, c, d)
  if t < d / 2 then
    return M.outQuint(t * 2, b, c / 2, d)
  else
    return M.inQuint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

function M.outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

function M.inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function M.outInSine(t, b, c, d)
  if t < d / 2 then
    return M.outSine(t * 2, b, c / 2, d)
  else
    return M.inSine((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inExpo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

function M.outExpo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

function M.inOutExpo(t, b, c, d)
  if t == 0 then
    return b
  end
  if t == d then
    return b + c
  end
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
end

function M.outInExpo(t, b, c, d)
  if t < d / 2 then
    return M.outExpo(t * 2, b, c / 2, d)
  else
    return M.inExpo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inCirc(t, b, c, d)
  t = t / d
  return (-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

function M.outCirc(t, b, c, d)
  t = t / d - 1
  return (c * sqrt(1 - pow(t, 2)) + b)
end

function M.inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

function M.outInCirc(t, b, c, d)
  if t < d / 2 then
    return M.outCirc(t * 2, b, c / 2, d)
  else
    return M.inCirc((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function M.inElastic(t, b, c, d, a, p)
  if t == 0 then
    return b
  end

  t = t / d

  if t == 1 then
    return b + c
  end

  if not p then
    p = d * 0.3
  end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  t = t - 1

  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
function M.outElastic(t, b, c, d, a, p)
  if t == 0 then
    return b
  end

  t = t / d

  if t == 1 then
    return b + c
  end

  if not p then
    p = d * 0.3
  end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
function M.inOutElastic(t, b, c, d, a, p)
  if t == 0 then
    return b
  end

  t = t / d * 2

  if t == 2 then
    return b + c
  end

  if not p then
    p = d * (0.3 * 1.5)
  end
  if not a then
    a = 0
  end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  else
    t = t - 1
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) * 0.5 + c + b
  end
end

-- a: amplitud
-- p: period
function M.outInElastic(t, b, c, d, a, p)
  if t < d / 2 then
    return M.outElastic(t * 2, b, c / 2, d, a, p)
  else
    return M.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

function M.inBack(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function M.outBack(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

---comment
---@param t any
---@param b any
---@param c any
---@param d any
---@param s any
---@return unknown
function M.inOutBack(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

function M.outInBack(t, b, c, d, s)
  if t < d / 2 then
    return M.outBack(t * 2, b, c / 2, d, s)
  else
    return M.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

function M.outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

function M.inBounce(t, b, c, d)
  return c - M.outBounce(d - t, 0, c, d) + b
end

function M.inOutBounce(t, b, c, d)
  if t < d / 2 then
    return M.inBounce(t * 2, 0, c, d) * 0.5 + b
  else
    return M.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
  end
end

function M.outInBounce(t, b, c, d)
  if t < d / 2 then
    return M.outBounce(t * 2, b, c / 2, d)
  else
    return M.inBounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end

return M
