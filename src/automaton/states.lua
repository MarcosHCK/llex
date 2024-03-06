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
local List = require ('pl.List')

--- @class States: { [integer[]]: integer }
local states = {}

do

  setmetatable (states,
    {
      __call = function (t, values)

        local self = List { }

        local pair_mt =
          {

            __tostring = function (p)

              return ('<%s, %d>'):format (tostring (p.key), p.value)
            end,
          }

        local self_mt =
          {

            __index = function (_, qs)

              for _, p in ipairs (self) do

                if (p.key == qs) then return p.value end
              end
            end,

            __newindex = function (_, qs, q)

              for _, p in ipairs (self) do

                if (p.key == qs) then p.value = q return end
              end

              List.append (self, setmetatable ({ key = qs, value = q }, pair_mt))
            end,

            __tostring = function () return tostring (self) end,
          }

        for qs, q in pairs (values) do self_mt.__newindex (nil, qs, q) end
        return setmetatable ({}, self_mt)
      end,
    })
return states
end
