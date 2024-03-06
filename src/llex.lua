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
local app = require ('pl.app')
local pathutils = require ('pl.path')

local function main ()

  app.require_here ()

  local argparse = require ('argparse')
  local templates = require ('templates')
  local parser = argparse ()

  parser:argument ('input', 'Input lexer definition')
  parser:option ('-o --output', 'Emit code to file')

  local args = parser:parse ()
  local input = assert (args.input)
  local output = io.stdout

  do
    local anchor = pathutils.abspath (pathutils.dirname (input))
    local anchored = pathutils.join (anchor, '.', '?.ll')
    local normal = pathutils.normpath (anchored)

    templates.path = table.concat ({ templates.path, normal }, package.config:sub (3, 3))
  end

  if (args.output and args.output ~= '-') then

    output = assert (io.open (args.output, 'w'))
  end

  local fp = assert (io.open (input, 'r'))
  local reader = function () local chunk = fp:read ('*l'); return chunk and (chunk .. '\n') end
  local template = assert (templates.compile (reader, '=' .. input))

  fp:close ()
  template (output)
end

---@diagnostic disable-next-line: undefined-global
main (args or arg or {...})
