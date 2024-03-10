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
--- @module 'templates.d'

include ('another')

NAME = 'name:(marcos|antonio)'
STRING = '"(\\\\.|[^"])*"'

function main ()

  assert (STRING, 'rule is not being set')
  assert (OPERATORS, 'include is not working')

  _ (require ('generators.json').emit (rules))
end
