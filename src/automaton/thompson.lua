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
local dfa = require ('automaton.dfa')

do
  ---
  --- Creates a NDFA (non-deterministic automata)
  ---
  --- @param a Automaton
  --- @param node AstNode
  --- @param q0? integer
  --- @param qf? integer
  --- @return Automaton
  --- @return integer q0
  --- @return integer qf
  ---
  local function create_ndfa (a, node, q0, qf)

    if q0 == nil then q0 = dfa.state (a) end
    if qf == nil then qf = dfa.state (a) end

    if (node.type == 'class'
      or node.type == 'literal'
      or node.type == 'nil') then

      assert (#node == 0)

      a:transition (q0, qf, node.value)

    elseif (node.type == 'factor') then

      assert (#node == 1)

      if (node.mod ~= '*') then

        a = create_ndfa (a, node[1], q0, qf)
      else

        local iq0, iqf

        a, iq0, iqf = create_ndfa (a, node[1])

        a:transition (q0, qf)
        a:transition (q0, iq0)
        a:transition (iqf, qf)
        a:transition (iqf, iq0)
      end
    elseif (node.type == 'group') then

      for _, term in ipairs (node) do

        assert (term.type == 'term')

        a = create_ndfa (a, term, q0, qf)
      end
    elseif (node.type == 'term') then

      if (#node == 1) then

        assert (node[1].type == 'factor')

        a = create_ndfa (a, node[1], q0, qf)
      else
        local last = q0

        for _, factor in ipairs (node) do

          assert (factor.type == 'factor')

          a, _, last = create_ndfa (a, factor, last)
        end

        a:transition (last, qf)
      end
    elseif (node.type == 'wildcard') then

      assert (#node == 0)

      a:transition (q0, qf, '.')
    else
      error (('unhandled AST node type \'%s\''):format (node.type))
    end
    return a, q0, qf
  end

  return create_ndfa
end
