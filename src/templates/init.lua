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
local compat = require ('compat')
local grammar = require ('templates.grammar')
local templates = {}

do
  ---
  --- Compiles a template
  ---
  --- @param source string | function
  --- @param chunkname? string
  --- @param mode? string
  --- @return any | nil
  --- @return string? reason
  ---
  function templates.compile (source, chunkname, mode)

    checks.arg (1, source, 'string', 'function')
    checks.optional (2, chunkname, 'string')
    checks.optional (3, mode, 'string')

    local global = {}
    local rules = {}

    global._G = global

    setmetatable (global,
      {
        __index = rules,

        __newindex = function (_, key, value)

          if (type (key) ~= 'string') then
            error ('rule name should be an string', 2)
          end
          if (type (value) ~= 'string') then
            error ('invalid rule value', 2)
          end

          if (not not rules[key]) then

            error ('attempt to redefine a rule', 2)
          else

            local ast, reason = grammar.parse (value)

            if (not ast) then

              error (reason, 2)
            else

              rules[key] = ast
            end
          end
        end,
      })

    local chunk, reason = compat.load (source, chunkname, mode, global)

    if (not chunk) then

      return nil, reason
    else

      local success, reason = pcall (chunk)

      if (not success) then

        return nil, reason
      else

        return rules
      end
    end
  end
return templates
end
