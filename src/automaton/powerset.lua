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
local Map = require ('pl.Map')
local Set = require ('pl.Set')
local States = require ('automaton.states')
local tablex = require ('pl.tablex')

--- @class Set<T>: table<T, any>

do
  ---
  --- Calculates the epsilon-closure for a given state
  ---
  --- @param a Automaton
  --- @param state integer
  --- @return Set<integer>
  ---
  local function eclosure (a, state)

    local closure = Set { state }

    for _, transition in ipairs (a.transitions[state] or {}) do

      if (not transition.over) then

        closure = Set.union (closure, eclosure (a, transition.to))
      end
    end
    return closure
  end

  ---
  --- Calculates the epsilon-closure for a given set of states
  ---
  --- @param a Automaton
  --- @param states Set<integer>
  --- @return Set<integer>
  ---
  local function eclosures (a, states)

    local closure = Set { }

    for state, _ in pairs (states) do

      closure = closure + eclosure (a, state)
    end
    return closure
  end

  local accumulate = function (s, e) return s + e end

  ---
  --- Detects if an state set contains a final state
  ---
  --- @param a Automaton
  --- @param states Set<integer>
  --- @return boolean
  ---
  local function has_final (a, states)

    local finals = tablex.reduce (accumulate, Set { }, a.finals)
    local hasit = not Set.isdisjoint (finals, states)
    return hasit
  end

  ---
  --- Creates a set state (or reuses one)
  ---
  --- @param a Automaton
  --- @param ndfa Automaton
  --- @param states States
  --- @param set Set<integer>
  --- @param new Set<Set<integer>>
  --- @return integer
  --- @return Set<Set<integer>>
  ---
  local function a_state (a, ndfa, states, set, new)

    if (states[set] ~= nil) then

      return states[set], new
    else

      local final = has_final (ndfa, set)
      local state = a:state (final)

      states[set] = state
      return state, List.append (new, set)
    end
  end

  ---
  --- Creates a DFA (deterministic automata)
  ---
  --- @param a Automaton
  --- @param ndfa Automaton
  --- @return Automaton a
  ---
  local function create_dfa (a, ndfa)

    local expander = function (set) return eclosures (ndfa, set) end
    local q0 = expander (Set { 0 })

    --- @type table<integer, integer[]>
    local wishlist = List { q0 }
    --- @type table<integer[], integer>
    local states = States { [q0] = 0 }

    while (List.len (wishlist) > 0) do

      local new = List { }
      local q1, q2
      local transitions = Map { }
      local wish = List.pop (wishlist)

      q1, new = a_state (a, ndfa, states, wish, new)

      for state, _ in pairs (wish) do

        for _, transition in ipairs (ndfa.transitions[state] or {}) do

          if (transition.over and not transitions[transition.over]) then
            transitions[transition.over] = Set { transition.to }
          elseif (transition.over and not not transitions[transition.over]) then
            transitions[transition.over] = transitions[transition.over] + transition.to
          end
        end
      end

      transitions = tablex.map (expander, transitions)

      for over, target in pairs (transitions) do

        q2, new = a_state (a, ndfa, states, target, new)

        a:transition (q1, q2, over)
      end

      List.extend (wishlist, new)
    end

    return a
  end

  return create_dfa
end
