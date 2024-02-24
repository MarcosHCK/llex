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
local utils = require ('utils')

TestVersion = {}

do

  function TestVersion:setUp ()

    self.originals = {}
    self.originals._VERSION = _G._VERSION
  end

  function TestVersion:tearDown ()

    _G._VERSION = self.originals._VERSION
  end

  function TestVersion:testGreaterThan ()

    local majors = { 5, 6 }
    local minors = { 1, 2, 3 }

    for _, major in ipairs (majors) do

      for _, minor in ipairs (minors) do

        _G._VERSION = ('Lua %d.%d'):format (major, minor)

        for _, innerMajor in ipairs (majors) do

          for _, innerMinor in ipairs (minors) do

            local checkEqual = major == innerMajor and minor == innerMinor
            local checkGreater = major > innerMajor or (major == innerMajor and minor > innerMinor)
            local checkLess = major < innerMajor or (major == innerMajor and minor < innerMinor)

            lu.assertEquals (utils.version.greaterThan (innerMajor, innerMinor), checkGreater)
            lu.assertEquals (utils.version.greaterOrEqualTo (innerMajor, innerMinor), checkEqual or checkGreater)
            lu.assertEquals (utils.version.lessThan (innerMajor, innerMinor), checkLess)
            lu.assertEquals (utils.version.lessOrEqualTo (innerMajor, innerMinor), checkEqual or checkLess)
            lu.assertEquals (utils.version.greaterThan (('%d.%d'):format (innerMajor, innerMinor)), checkGreater)
            lu.assertEquals (utils.version.greaterOrEqualTo (('%d.%d'):format (innerMajor, innerMinor)), checkEqual or checkGreater)
            lu.assertEquals (utils.version.lessThan (('%d.%d'):format (innerMajor, innerMinor)), checkLess)
            lu.assertEquals (utils.version.lessOrEqualTo (('%d.%d'):format (innerMajor, innerMinor)), checkEqual or checkLess)

            if (major == innerMajor) then

              lu.assertEquals (utils.version.greaterThan (innerMinor), checkGreater)
              lu.assertEquals (utils.version.greaterOrEqualTo (innerMinor), checkEqual or checkGreater)
              lu.assertEquals (utils.version.lessThan (innerMinor), checkLess)
              lu.assertEquals (utils.version.lessOrEqualTo (innerMinor), checkEqual or checkLess)
              lu.assertEquals (utils.version.greaterThan (('%d'):format (innerMinor)), checkGreater)
              lu.assertEquals (utils.version.greaterOrEqualTo (('%d'):format (innerMinor)), checkEqual or checkGreater)
              lu.assertEquals (utils.version.lessThan (('%d'):format (innerMinor)), checkLess)
              lu.assertEquals (utils.version.lessOrEqualTo (('%d'):format (innerMinor)), checkEqual or checkLess)
            end
          end
        end
      end
    end
  end

return os.exit (lu.LuaUnit.run ())
end
