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

package.path = table.concat ({ package.path, './?.lua' }, ';')
package.path = table.concat ({ package.path, './?/init.lua' }, ';')

local function main (cmdline)

  local argparse = require ('argparse')
  local templates = require ('templates')
  local parser = argparse ()

  parser:argument ('input', 'Input lexer definition')

  local args = parser:parse ()
  local input = assert (args.input)

  local fp = assert (io.open (input, 'r'))
  local reader = function () local chunk = fp:read ('*l'); return chunk and (chunk .. '\n') end
  local rules = assert (templates.compile (reader, '=' .. input))

  --require ('pl.pretty').dump (rules)

  local file = assert (io.open ('rules.json', 'w'))
  file:write (require ('json.encode').encode (rules))
  file:close ()
end

---@diagnostic disable-next-line: undefined-global
main (args or arg or {...})
