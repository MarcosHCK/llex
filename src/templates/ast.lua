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
local ast = {}
local lpeg = require ('lpeglabel')
local utils = require ('pl.utils')

do

  local function branchAccummulator (list, item)

    table.insert (list, item)
    return list
  end

  local function branchMakeup (capture)

    if (capture[1] ~= nil) then

      local children = capture[1]

      table.remove (capture, 1)

      for _, node in ipairs (children) do

        table.insert (capture, node)
      end
    end
    return capture
  end

  ---
  --- Creates a pattern which captures @pattern as an AST node, where @pattern,
  --- could appear one or more times, thus creating a branched (multiple) node
  ---
  --- @param type string
  --- @param pattern userdata | string
  --- @param sep? userdata | string
  --- @return userdata capture
  ---
  function ast.branch (type, pattern, sep)

    local head = pattern
    local tail = not sep and pattern or sep * pattern
    local accumulate = lpeg.Cf (lpeg.Ct (head) * tail ^ 0, branchAccummulator)
    local capture = ast.node (type, accumulate) / branchMakeup
    return capture
  end

  ---
  --- Creates a pattern which captures @pattern as an AST node, tagging it as a
  --- node 'value' (literally a node field named 'value')
  ---
  --- @param type string
  --- @param pattern userdata | string
  --- @return userdata
  ---
  function ast.leaf (type, pattern)

    return ast.node (type, lpeg.Cg (pattern, 'value'))
  end

  ---
  --- Creates a pattern which captures @pattern as an AST node
  ---
  --- @param type_ string
  --- @param pattern userdata | string
  --- @return userdata capture
  ---
  function ast.node (type_, pattern)

    local applt = function (t) t.type = t.type == '' and type_ or t.type; return t end
    local position = lpeg.Cg (lpeg.Cp (), 'position')
    local type = lpeg.Cg (lpeg.C (''), 'type')

    return lpeg.Ct (type * position * pattern) / applt
  end

return ast
end
