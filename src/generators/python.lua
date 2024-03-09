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
--- @module 'templates.d'
local d
local encoder = require ('json.encode')
local generator = {}
local over = require ('automaton.over')
local template = require ('pl.template')

do

  local emitfactible

  ---
  --- @param rules Rules
  --- @return string
  ---
  function generator.emit (rules)

    local name = 'generators/python.py'
    local file = assert (io.open (name, 'r'))
    local data = assert (file:read ('*a'))

    local options =
      {
        chunk_name = '=' .. name,
        escape = '##',
        inline_escape = 'f',
        inline_brackets = '\"\"',
      }

    local global = { over = over, rules = rules }

    file:close ()

    local ct = assert (template.compile (data, options))
    local rr = assert (ct:render (nil, setmetatable (global, { __index = _G })))
    return rr
  end

return generator
end
