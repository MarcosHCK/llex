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
local checks = require ('utils.checks')
local version = setmetatable ({}, { __call = function () return _VERSION end })

do

  ---
  --- Check if local version is LuaJIT
  ---
  version.isJIT = pcall (require, 'jit')

  --- @return number local_major
  --- @return number local_minor
  local function getLocalVersion ()

    local major, minor = (version ()):match ('^Lua%s([%d]+)%.([%d]+)$')
    return assert (tonumber (major)), assert (tonumber (minor))
  end

  --- @param minorOrMajor number | string
  --- @param maybeMinor? number
  --- @return number against_major
  --- @return number against_minor
  local function getVersionAgainst (minorOrMajor, maybeMinor)

    checks.argAtLevel (1, 1, minorOrMajor, 'number', 'string')
    checks.argAtLevel (1, 2, maybeMinor, 'number', 'nil')

    if (type (minorOrMajor) == 'string') then

      if (minorOrMajor:match ('^[%d]+$')) then

        local minor = minorOrMajor:match ('^([%d]+)$')
        return getVersionAgainst (assert (tonumber (minor)))
      elseif (minorOrMajor:match ('^[%d]+%.[%d]+$')) then

        local major, minor = minorOrMajor:match ('^([%d]+)%.([%d]+)$')
        return getVersionAgainst (assert (tonumber (major)), assert (tonumber (minor)))
      else

        error (('Malformed version %s'):format (minorOrMajor), 2)
      end
    else

      if (maybeMinor ~= nil) then

        return minorOrMajor, maybeMinor
      else

        local localMayor = (version ()):match ('^Lua%s([%d]+)%.([%d]+)$')
        return assert (tonumber (localMayor)), minorOrMajor
      end
    end
  end

  ---
  --- Checks if runtime Lua version is greater or equal to an specific version
  ---
  --- @param minorOrMajor number | string
  --- @param maybeMinor? number
  --- @return boolean
  ---
  function version.greaterOrEqualTo (minorOrMajor, maybeMinor)

    local fa, fb = getVersionAgainst (minorOrMajor, maybeMinor)
    local ta, tb = getLocalVersion ()
    return ta > fa or (ta == fa and tb >= fb)
  end

  ---
  --- Checks if runtime Lua version is greater than an specific version
  ---
  --- @param minorOrMajor number | string
  --- @param maybeMinor? number
  --- @return boolean
  ---
  function version.greaterThan (minorOrMajor, maybeMinor)

    local fa, fb = getVersionAgainst (minorOrMajor, maybeMinor)
    local ta, tb = getLocalVersion ()
    return ta > fa or (ta == fa and tb > fb)
  end

  ---
  --- Checks if runtime Lua version is greater than an specific version
  ---
  --- @param minorOrMajor number | string
  --- @param maybeMinor? number
  --- @return boolean
  ---
  function version.lessThan (minorOrMajor, maybeMinor)

    local fa, fb = getVersionAgainst (minorOrMajor, maybeMinor)
    local ta, tb = getLocalVersion ()
    return ta < fa or (ta == fa and tb < fb)
  end

  ---
  --- Checks if runtime Lua version is greater or equal to an specific version
  ---
  --- @param minorOrMajor number | string
  --- @param maybeMinor? number
  --- @return boolean
  ---
  function version.lessOrEqualTo (minorOrMajor, maybeMinor)

    local fa, fb = getVersionAgainst (minorOrMajor, maybeMinor)
    local ta, tb = getLocalVersion ()
    return ta < fa or (ta == fa and tb <= fb)
  end
return version
end
