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
local bounds = require ('automaton.bounds')
local over = {}

--- @alias OverChar Bounds | string
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

    local prefix = negated and 'n' or ''

    if (type == 'literal') then

    elseif (type == 'set') then

      local lower = value.lower
      local upper = value.upper

      value = ('%s-%s'):format (lower, upper)
    else

      error (('Unknown class type %s'):format (type))
    end

    return ('%s%s%s'):format (prefix, type:sub (1, 1), value)
  end

  ---
  --- Unserialized an over (transition value)
  ---
  --- @param value string
  --- @return OverChar value_char
  --- @return OverType value_type
  --- @return boolean negated
  ---
  function over.deserialize (value)

    local n, t, lower, o, upper = string.match (value, '(n?)(.)(.)(-?)(.?)')

    local negated = n ~= ''
    local type = assert (types [t], 'unknown class type ' .. t)

    assert (type ~= 'set' or (o ~= '' and upper ~= ''))
    return o == '' and lower or bounds.new (lower, upper), type, negated
  end

return over
end
