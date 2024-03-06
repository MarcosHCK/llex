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
local lu = require ('tests.base')
local checks = require ('utils.checks')

TestChecks = {}

do

  local function checkerArg (a, ...) checks.arg (1, a, ...) error ('good!') end
  local function checkerOptional (a, ...) checks.optional (1, a, ...) error ('good!') end

  function TestChecks:testArg ()

    lu.assertErrorMsgContains ('bad argument', checkerArg, nil, 'string')
    lu.assertErrorMsgContains ('bad argument', checkerArg, nil, 'string', 'number')
    lu.assertErrorMsgContains ('bad argument', checkerArg, 1, 'string', 'nil')
    lu.assertErrorMsgContains ('bad argument', checkerArg, true, 'string', 'nil')
    lu.assertErrorMsgContains ('good!', checkerArg, 1, 'number')
    lu.assertErrorMsgContains ('good!', checkerArg, nil, 'number', 'nil')
  end

  function TestChecks:testOptional ()

    lu.assertErrorMsgContains ('bad argument', checkerOptional, 1, 'string')
    lu.assertErrorMsgContains ('bad argument', checkerOptional, 1, 'string', 'boolean')
    lu.assertErrorMsgContains ('bad argument', checkerOptional, true, 'string', 'number')
    lu.assertErrorMsgContains ('good!', checkerOptional, 1, 'number')
    lu.assertErrorMsgContains ('good!', checkerOptional, nil, 'number')
  end
end
