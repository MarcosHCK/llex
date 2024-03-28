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
--
local compat = require ('pl.compat')
local OrderedMap = require ('pl.OrderedMap')
local pathutils = require ('pl.path')
local rule = require ('templates.rule')
local templates = {}
local utils = require ('pl.utils')

do

  ---
  --- Similar to package.path for templates.include
  --- @type string
  ---
  templates.path = '?.lua'

  --- @param from string
  --- @param name string
  --- @param iffailed string
  --- @return any
  ---
  local function pick (from, name, iffailed)

    local base = utils.assert_string (1, name)
    local path = pathutils.normpath (base)

    assert (not path:match ('[%/]'), string.format (iffailed, name))

    local success, result = pcall (require, ('%s.%s'):format (from, path))
    local picked = assert (success and result, string.format (iffailed, name))
    return picked
  end

  local function printf (stdout, ...)

    local pre = ''

    for _, arg in ipairs ({ ... }) do

      stdout:write (tostring (arg) .. pre)
      pre = '\t'
    end

    stdout:write ('\n')
  end

  ---
  --- Compiles a template
  ---
  --- @param source string | function
  --- @param chunkname? string
  --- @param mode? string
  --- @return any | nil
  --- @return (string | table)? reasonOrGlobal
  ---
  function templates.compile (source, chunkname, mode)

    if (type (source) ~= 'string' and type (source) ~= 'function') then

      utils.assert_arg (1, source, 'string')
    end

    if (chunkname ~= nil) then utils.assert_arg (2, chunkname, 'string') end
    if (mode ~= nil) then utils.assert_arg (3, mode, 'string') end

    local global
    local global_mt

    --- @type Generator
    local generator = nil
    --- @type table<string, Automaton>
    local rules = OrderedMap { }

    global =
      {

        --- @type fun(...: string): any
        ---
        fail = function (...) return printf (io.stderr, ...) end,

        --- @type fun(name: string)
        ---
        generator = function (name)

          assert (not generator, 'parser generator was already defined')
          generator = pick ('generators', name, 'invalid generator \'%s\'')
        end,
      }

    global_mt =
      {
        __index = function (_, k) return rules[k] or _G[k] end,

        __newindex = function (t, key, value)

          if (key == 'main') then

            assert (rawget (t, key) == nil, 'redefining template main')
            rawset (t, key, value)
          else

            assert (type (key) == 'string', 'rule name should be an string')
            assert (type (value) == 'string', 'invalid rule value')
            assert (not rules[key], 'attempt to redefine a rule')

            OrderedMap.set (rules, key, rule.compile (value))
          end
        end,
      }

    global._G = global

    local chunk, reason = compat.load (source, chunkname, mode, setmetatable (global, global_mt))

    if (not chunk) then return nil, reason
    else

      local success, result = xpcall (chunk, function (msg)

        return debug.traceback (msg)
      end)

      if (not success) then return nil, result
      else

        local env = setmetatable ({}, { __index = global })
        local main = global.main or (function ()

          env._ (assert (env.generator, 'lexer generator was not defined').emit (env.rules))
        end)

        env._G = env
        env.generator = generator
        env.rules = rules

        return function (stdout)

          env._ = function (...) printf (stdout, ...) end
          return (compat.setfenv (main, env)) (stdout)
        end
      end
    end
  end
return templates
end
