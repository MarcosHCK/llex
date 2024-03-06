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
local ast = require ('templates.ast')
local grammar = {}
local lpeg = require ('lpeglabel')
local re = require ('relabel')

do

  local errors =
    {
      fail = 'undefined error',

      -- Errors
      emptyRule = 'empty rule',
      expectedBracket = 'missing \']\' char to close character class',
      expectedParenthesis = 'missing \')\' char to close group',
      missingEscapee = 'missing escapee char from escape sequence',
      missingTerm = 'missing term after \'|\' operator',
      unexpectedChar = 'unexpected char',
    }

  local class = lpeg.V 'class'
  local escape = lpeg.V 'escape'
  local expression = lpeg.V 'expression'
  local factor = lpeg.V 'factor'
  local group = lpeg.V 'group'
  local literal = lpeg.V 'literal'
  local primary = lpeg.V 'primary'
  local regex = lpeg.V 'regex'
  local term = lpeg.V 'term'
  local wildcard = lpeg.V 'wildcard'

  local emptyRule = lpeg.T 'emptyRule'
  local expectedBracket = lpeg.T 'expectedBracket'
  local expectedParenthesis = lpeg.T 'expectedParenthesis'
  local missingEscapee = lpeg.T 'missingEscapee'
  local missingTerm = lpeg.T 'missingTerm'
  local unexpectedChar = lpeg.T 'unexpectedChar'

  local modifiers = lpeg.S '*+?'
  local specials = lpeg.S '.*+?|()[]\\'

  local q = function (c, a, b) if (c) then return a else return b end end
  local unmod = function (t) t.mod = q (t.mod == '', nil, t.mod); return t end

  local parser = lpeg.P (
    {
      regex,

      -- Rules
      class = ast.leaf ('class', '[' * lpeg.C ((1 - lpeg.P ']') ^ 0) * (']' + expectedBracket)),
      escape = ast.leaf ('literal', '\\' * lpeg.C (1 + missingEscapee)),
      expression = (term * ('|' * (term + (-1 * missingTerm) + unexpectedChar)) ^ 0) + unexpectedChar,
      factor = ast.node ('factor', primary * lpeg.Cg (modifiers ^ -1, 'mod')) / unmod,
      group = ast.node ('group', '(' * expression * (')' + (-1 * expectedParenthesis) + unexpectedChar)),
      literal = ast.leaf ('literal', lpeg.C (1 - specials)),
      primary = literal + group + class + wildcard + escape,
      regex = ast.node ('group', expression + emptyRule) * (-1 + unexpectedChar),
      term = ast.branch ('term', factor, nil),
      wildcard = ast.node ('wildcard', lpeg.P '.'),
    })

  ---
  --- Parse a regular expression into an AST tree
  ---
  --- @param source string
  --- @return AstNode | nil ast
  --- @return string? reason
  --- @return number? line
  --- @return number? column
  ---
  function grammar.parse (source)

    local tree, e, position = parser:match (source)

    if (not not tree) then

      return tree
    else

      local line, column = re.calcline (source, position)
      local reason = errors[e]

      if (e == 'unexpectedChar') then

        local where = assert (tonumber (position), 'non-numeric fail position')
        local char = source:sub (where, where)

        reason = ('%s %s'):format (reason, char)
      end
      return nil, reason, line, column
    end
  end
return grammar
end
