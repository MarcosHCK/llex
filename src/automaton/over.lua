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
local over = {}

--- @alias OverChar boolean | nil | string
--- @alias OverType  'literal' | 'set'

do

  local types = { l = 'literal', s = 'set' }

  ---
  --- Serializes an over (transition value)
  ---
  --- @param value OverChar
  --- @param type OverType
  --- @param negated? boolean
  --- @return string
  ---
  function over.serialize (value, type, negated)

    return ('%s%s%s'):format (negated and 'n' or '', type:sub (1, 1), value)
  end

  ---
  --- Unserialized an over (transition value)
  ---
  --- @param value string
  --- @return OverChar value_char
  --- @return OverType value_type
  --- @return boolean nagated
  ---
  function over.unserialize (value)

    if (value:sub (1, 1) == 'n') then

      local v, t = over.unserialize (value)
      return v, t, true
    else

      local v = value:sub (2)
      local t = types[value:sub (1, 1)]

      --- @cast t OverType
      return v, t, false
    end
  end

return over
end
