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
local checks = {}

do

  local function check (have, want, ...)

    if (not want) then

      return false
    else

      return have == want or check (have, ...)
    end
  end

  ---
  --- Guards against function argument type mismatches (it work at runtime of course)
  ---
  --- @param n number
  --- @param have any
  --- @param ... string
  --- @return nil
  ---
  function checks.arg (n, have, ...)

    checks.argAtLevel (1, n, have, ...)
  end

  ---
  --- Guards against function argument type mismatches (it work at runtime of course)
  ---
  --- @param n number
  --- @param have any
  --- @param ... string
  --- @return nil
  ---
  function checks.argAtLevel (level, n, have, ...)

    have = type (have)

    if (not check (have, ...)) then

      error (('bad argument #%d (%s expected, got %s)'):format (n, table.concat ({...}, " or "), have), level + 3)
    end
  end

  ---
  --- Same as .arg but making argument optional
  ---
  --- @param n number
  --- @param have any
  --- @param ... string
  --- @return nil
  ---
  function checks.optional (n, have, ...)

    checks.argAtLevel (1, n, have, 'nil', ...)
  end

  ---
  --- Same as .argAtLevel but making argument optional
  ---
  --- @param n number
  --- @param have any
  --- @param ... string
  --- @return nil
  ---
  function checks.optionalAtLevel (level, n, have, ...)

    checks.argAtLevel (level + 1, n, have, 'nil', ...)
  end
return checks
end
