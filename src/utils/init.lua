--[[
-- Copyright 2021-2025 MarcosHCK
-- This file is part of llex.
--
-- llex is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- llex is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with llex.  If not, see <http://www.gnu.org/licenses/>.
]]
local utils = {}

do

  utils.checks = require ('utils.checks')
  utils.version = require ('utils.version')

  ---
  --- Emulates ?: operator (ternary operator) from C (and-or pattern exists in
  --- Lua, I known, but it gives inconsistent results when nil is involved)
  --- Be known that whenTrue and whenFalse expression are executed *before*
  --- any consideration is made (say, before is decided whether one or the another
  --- to use, given condition is met or not), so there is not short-circuit here
  --- (not lazy execution, so side effects are performed for both arguments)
  ---
  --- @generic T1, T2
  --- @param condition boolean condition to check
  --- @param whenTrue T1 value to return when condition is met
  --- @param whenFalse T2 value to return when condition is not met
  --- @return T1 | T2 result either whenTrue or whenFalse
  ---
  function utils.q (condition, whenTrue, whenFalse)

    if (condition) then

      return whenTrue
    else
      return whenFalse
    end
  end
return utils
end
