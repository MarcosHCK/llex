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
local List = require ('pl.List')
local utils = require ('pl.utils')

--- @class Automaton
--- @field private next integer
--- @field public finals integer[]
--- @field public transitions table<integer, Transition[]>
local dfa = {}

--- @class Transition
--- @field public over? string
--- @field public to integer

do
  ---
  --- Creates a new automata (whether it is deterministic or not)
  ---
  --- @return Automaton
  ---
  function dfa.new ()

    --- @type Automaton
    local t = { next = 1, finals = List { }, transitions = { } }
    return setmetatable (t, { __index = dfa })
  end

  ---
  --- Adds an state
  ---
  --- @param a Automaton
  --- @param final? boolean
  --- @return integer state_index
  ---
  function dfa.state (a, final)

    utils.assert_arg (1, a, 'table')

    if (final == nil) then

      final = false
    else

      utils.assert_arg (2, final, 'boolean')
    end

    local idx = a.next

    if (final) then

      List.append (a.finals, idx)
    end

    a.next = a.next + 1
    return idx
  end

  ---
  --- Adds a transition from state from to state to over character over
  ---
  --- @param a Automaton
  --- @param from integer
  --- @param to integer
  --- @param over? boolean | string
  ---
  function dfa.transition (a, from, to, over)

    utils.assert_arg (1, a, 'table')
    utils.assert_arg (2, from, 'number')
    utils.assert_arg (3, to, 'number')

    if (not a.transitions [from]) then

      a.transitions [from] = List {{ to = to, over = over }}
    else

      List.append (a.transitions [from], { to = to, over = over })
    end
  end
return dfa
end
