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
local dfa = require ('automaton')
local grammar = require ('templates.grammar')
local rule = {}

do
  ---
  --- Compiles a rule to an equivalent DFA
  ---
  --- @param pattern string
  --- @return Automaton | nil automaton
  --- @return string? reason
  ---
  function rule.compile (pattern)

    local ast, reason = grammar.parse (pattern)

    if (not ast) then

      return nil, reason
    else

      return dfa.create (ast)
    end
  end
return rule
end
