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

  -- Rules
  local boundRule = lpeg.V 'bound'
  local charsetRule = lpeg.V 'charset'
  local classRule = lpeg.V 'class'
  local escapeRule = lpeg.V 'escape'
  local expressionRule = lpeg.V 'expression'
  local factorRule = lpeg.V 'factor'
  local groupRule = lpeg.V 'group'
  local literalRule = lpeg.V 'literal'
  local primaryRule = lpeg.V 'primary'
  local regexRule = lpeg.V 'regex'
  local termRule = lpeg.V 'term'
  local wildcardRule = lpeg.V 'wildcard'

  -- Errors (references)
  local emptyRule = lpeg.T 'emptyRule'
  local expectedBracket = lpeg.T 'expectedBracket'
  local expectedParenthesis = lpeg.T 'expectedParenthesis'
  local missingEscapee = lpeg.T 'missingEscapee'
  local missingTerm = lpeg.T 'missingTerm'
  local unexpectedChar = lpeg.T 'unexpectedChar'

  -- Patterns
  local modifiers = lpeg.S '*+?'
  local negator = lpeg.P '^'
  local specials = lpeg.S '.*+?|()[]\\'

  local bound = lpeg.C (1 - lpeg.P ']')
  local class = (charsetRule + boundRule + escapeRule) ^ 1
  local escape = '\\' * lpeg.C (1 + missingEscapee)
  local literal = lpeg.C (1 - specials)

  -- Errors (messages)
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

  local unmod = function (t) if (t[ast.modTag] == '') then t[ast.modTag] = nil end return t end
  local unneg = function (t) if (t[ast.negTag] == '') then t[ast.negTag] = nil else t[ast.negTag] = true end return t end

  local parser = lpeg.P (
    {
      regexRule,

      -- Rules
      bound = ast.node ('literal', lpeg.Cg (bound, ast.valueTag)),
      charset = ast.node ('charset', lpeg.Cg (bound + escape, 'lower') * '-' * (lpeg.Cg (bound + escape, 'upper'))),
      class = ast.node ('class', '[' * lpeg.Cg (negator ^ -1, ast.negTag) * class * (']' + expectedBracket)) / unneg,
      escape = ast.node ('literal', lpeg.Cg (escape, ast.valueTag)),
      expression = (termRule * ('|' * (termRule + (-1 * missingTerm) + unexpectedChar)) ^ 0) + unexpectedChar,
      factor = ast.node ('factor', primaryRule * lpeg.Cg (modifiers ^ -1, ast.modTag)) / unmod,
      group = ast.node ('group', '(' * expressionRule * (')' + (-1 * expectedParenthesis) + unexpectedChar)),
      literal = ast.node ('literal', lpeg.Cg (literal, ast.valueTag)),
      primary = literalRule + groupRule + classRule + wildcardRule + escapeRule,
      regex = ast.node ('group', expressionRule + emptyRule) * (-1 + unexpectedChar),
      term = ast.branch ('term', factorRule, nil),
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
