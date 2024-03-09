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
-- ]]

--- @meta
--- @module 'automaton.dfa'

--- @alias Rule Automaton
--- @alias Rules table<string, Rule>

---
--- Template entry point (expressions are valid outside but code generation
--- is restricted to this function's scope)
--- @type fun(tout: file*)
---
main = nil

---
--- Template rules (defined inside 'main' function's scope)
--- @type Rules
---
rules = nil

---
--- Prints some output to the template output stream (like file:write (...))
--- Note: is only defined inside template's main function
---
--- @param ... string
---
function _ (...) end

---
--- See io.stderr:write (...)
--- @param ... string
---
function fail (...) end

---
--- See description for templates.include
--- @source init.lua:92
---
--- @param name string
--- @return fun(tout: file*) template_main
---
function include (name) end
