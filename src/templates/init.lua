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
local compat = require ('pl.compat')
local OrderedMap = require ('pl.OrderedMap')
local rule = require ('templates.rule')
local tablex = require('pl.tablex')
local templates = {}
local utils = require ('pl.utils')

do

  ---
  --- Similar to package.path for templates.include
  --- @type string
  ---
  templates.path = '?.lua'

  --- @generic T
  --- @param level number
  --- @param cond? T
  --- @param message? any
  --- @param ... any
  --- @return T
  --- @return any ...
  local function levelAssert (level, cond, message, ...)

    if (not cond) then

      error (message, level + 1)
    else
      return cond, message, ...
    end
  end

  --- @generic T
  --- @param global table
  --- @param rules table
  --- @param chunk function | nil
  --- @param reason? string
  --- @return nil | fun(tout: file*) template
  --- @return (string | table)? reasonOrGlobal
  local function loadCapture (global, rules, chunk, reason)

    if (not chunk) then

      return nil, reason
    else

      local success, result = pcall (chunk)

      if (not success) then

        return nil, result
      elseif (not global.main) then

        return function () end, rules
      else

        return function (tout)

          local env = setmetatable ({ }, { __index = global })
          local fun = compat.setfenv (global.main, env)

          env._G = env
          env.rules = tablex.deepcopy (rules)
          env['_'] = function (...) tout:write (..., '\n') end
          return fun (tout)
        end, rules
      end
    end
  end

  ---
  --- Includes a foreigh template into the current running one
  ---
  --- @param name string
  ---
  function templates.include (name)

    local file, reason = package.searchpath (name, templates.path)

    if (not file) then

      return nil, reason
    else

      local fp, reason = io.open (file, 'r')

      if (not fp) then

        return nil, reason
      else

        local reader = function () local chunk = fp:read ('*l'); return chunk and (chunk .. '\n') end
        local results = { templates.compile (reader, ('=%s'):format (name)) }
        fp:close ()

        return utils.unpack (results)
      end
    end
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

    local global = { }
    local rules = OrderedMap { }

    global._G = global
    global.fail = function (...) return io.stderr:write (..., '\n') end
    global.include = function (name)

      local main, newrules = levelAssert (2, templates.include (name))
      for k, rule in pairs (newrules) do OrderedMap.set (rules, k, rule) end
      return main
    end

    setmetatable (global,
      {
        __index = function (_, k)

          return rules[k] or _G[k]
        end,

        __newindex = function (t, key, value)

          if (key == 'main') then

            if (not rawget (t, key)) then

              rawset (t, key, value)
            else

              error ('redefining lexer main function')
            end
          else

            if (type (key) ~= 'string') then error ('rule name should be an string', 2) end
            if (type (value) ~= 'string') then error ('invalid rule value', 2) end

            if (not not rules[key]) then

              error ('attempt to redefine a rule', 2)
            else

              OrderedMap.set (rules, key, levelAssert (2, rule.compile (value)))
            end
          end
        end,
      })

    return loadCapture (global, rules, compat.load (source, chunkname, mode, global))
  end
return templates
end
