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
local compat = {}
local version = require ('utils.version')

do
  ---
  --- Compatibility layer for load
  ---
  --- @param source string | function
  --- @param chunkname? string
  --- @param mode? loadmode
  --- @param env? table
  --- @return function | nil chunk
  --- @return string? reason
  function compat.load (source, chunkname, mode, env)

    if (version.greaterThan (5, 1) or version.isJIT) then

      return load (source, chunkname, mode, env)
    elseif (type (source) == 'function') then

      local chunk, reason = load (source, chunkname)

      if (not chunk) then

        return nil, reason
      else

        ---@diagnostic disable-next-line: deprecated
        local enved = setfenv (chunk, env or _G)
        return enved
      end
    else

      ---@diagnostic disable-next-line: deprecated
      local chunk, reason = loadstring (source, chunkname)

      if (not chunk) then

        return nil, reason
      else

        ---@diagnostic disable-next-line: deprecated
        local enved = setfenv (chunk, env or _G)
        return enved
      end
    end
  end
return compat
end
