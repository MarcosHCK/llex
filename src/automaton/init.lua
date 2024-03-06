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
local ast = require ('automaton.ast')
local create_dfa = require ('automaton.powerset')
local create_ndfa = require ('automaton.thompson')

--- @class Autom4ton: Automaton
local dfa = require ('automaton.dfa')

do
  ---
  --- Creates a DFA (deterministic finite automata) which recognizes the
  --- string matching the formal regular expression represented by tree
  ---
  --- @param tree AstNode
  --- @return Automaton
  ---
  function dfa.create (tree)

    local canon = ast.expand (tree)
    local dfa_, ndfa_

    do
      local a = dfa.new ()
      local qf = a:state (true)

      ndfa_ = create_ndfa (a, canon, 0, qf)
    end

    do
      local a = dfa.new ()

      dfa_ = create_dfa (a, ndfa_)
    end

    return dfa_
  end
return dfa
end
