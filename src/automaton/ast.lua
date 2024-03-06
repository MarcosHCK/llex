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
local ast = {}
local checks = require ('utils.checks')

--- @alias AstModifier
--- | '+'
--- | '*'
--- | '?'

--- @alias AstType
--- | 'class'
--- | 'factor'
--- | 'group'
--- | 'literal'
--- | 'nil'
--- | 'regex'
--- | 'term'
--- | 'wildcard'

--- @class AstNode
--- @field public mod? AstModifier
--- @field public type AstType
--- @field public value string

local q = function (c, a, b) if (c) then return a else return b end end

do
  ---
  --- Adds an AST node to another one as a child (no type check is done so you,
  --- are free to make as many mistakes as you want)
  ---
  --- @param parent AstNode
  --- @param child AstNode
  --- @return AstNode tree
  ---
  function ast.append (parent, child)

    checks.arg (1, parent, 'table')
    checks.arg (1, child, 'table')
    table.insert (parent, child)
    return parent
  end

  ---
  --- Copies an AST node (an all its children if instructed)
  ---
  --- @param root AstNode
  --- @param childrenToo? boolean
  --- @return AstNode copy
  ---
  function ast.copy (root, childrenToo)

    checks.arg (1, root, 'table')
    checks.optional (2, childrenToo, 'boolean')

    local result = ast.node (root.type, root.value, root.mod)

    for _, node in ipairs (root) do

      --- @cast node AstNode
      table.insert (result, q (not childrenToo, node, ast.copy (node, true)))
    end
    return result
  end

  ---
  --- Expands a regular expression AST into a formal regular expression AST
  --- (if you can't tell the difference please search it, is really interesting)
  ---
  --- @param node AstNode
  --- @return AstNode ast
  ---
  function ast.expand (node)

    checks.arg (1, node, 'table')

    for i, child in ipairs (node) do

      node[i] = ast.expand (child)
    end

    if (node.mod == '?') then

      assert (#node == 1)

      local group = ast.node ('group')
      local null = ast.append (ast.node ('factor'), ast.node ('nil'))

      ast.append (group, ast.append (ast.node ('term'), node))
      ast.append (group, ast.append (ast.node ('term'), null))
      return ast.append (ast.node ('factor'), group)
    elseif (node.mod == '+') then

      assert (#node == 1)

      local factor = ast.node ('factor')
      local group = ast.node ('group')
      local multiple = node
      local single = ast.copy (node)
      local term = ast.node ('term')

      single.mod = nil
      multiple.mod = '*'

      ast.append (term, single)
      ast.append (term, multiple)
      ast.append (group, term)
      ast.append (factor, group)

      return factor
    end
    return node
  end

  ---
  --- Creates an automaton AST node
  ---
  --- @param type AstType
  --- @param value? string
  --- @param modifier? AstModifier
  --- @return AstNode node
  ---
  function ast.node (type, value, modifier)

    checks.arg (1, type, 'string')
    checks.optional (2, value, 'string')
    checks.optional (3, modifier, 'string')

    return { mod = modifier, type = type, value = value }
  end
return ast
end
