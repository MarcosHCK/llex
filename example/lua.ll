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

INLINE_COMMENT = '--[^\n]*'
MULTILINE_COMMENT = '--\\[\\[[^\\]]*\\]\\]'

KEYWORD = 'do|end|for|in|repeat|until|while|else|elseif|if|then|local|break|function|return'

BINARY_OPERATOR = '[-+*/%^<>]|(<=)|(>=)|(==)|(~=)|(\\.\\.)'
UNARY_OPERATOR = 'and|or|not|#|\\.\\.\\.'

IDENTIFIER = '[a-zA-Z_][a-zA-Z_0-9]*'
NUMBER = '[0-9]+(\\.[0-9]+)?'
VALUE = 'false|nil|true|\'(\\\\.|[^\'])*\'|"(\\\\.|[^"])*"'

ASSIGN = '='
TABLE_INDEXING = '\\.'
TABLE_METHOD = '\\:'
COMMA = ','

L_BRACKET = '[\\[]'
R_BRACKET = '[\\]]'
L_KEY = '[\\{]'
R_KEY = '[\\}]'
L_PARENTHESIS = '[\\(]'
R_PARENTHESIS = '[\\)]'

IGNORE = '[ \t\n\r;]'

function main ()

  _ (require ('generators.python').emit (rules))
end
