# Copyright 2021-2025 MarcosHCK
# This file is part of llex.
#
# llex is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# llex is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with llex.  If not, see <http://www.gnu.org/licenses/>.
#
from collections import namedtuple
from typing import Dict, Iterable, Iterator, List

Token = namedtuple ('Token', [ 'type', 'value' ])
Transition = namedtuple ('Transition', [ 'factible', 'to' ])

class LexerException (Exception):

  position: int
  value: str

  def __init__ (self, position, value) -> None:

    super ().__init__ ()

    self.position = position - len (value)
    self.value = value

  def __str__ (self) -> str:

    return f'{self.position}: unknown token \'{self.value}\''

class LexerRule:

  current: int
  finals: List[int]
  stopped: bool
  table: Dict[int, List[Transition]]

  def __init__ (self, finals: List[int], table: Dict[int, List[Transition]]):

    self.finals = finals
    self.table = table

    self.reset ()

  def feed (self, char: str) -> bool:

    if not self.stopped:

      for transition in self.table.get (self.current, [ ]):

        if (transition.factible (char)):

          self.current = transition.to

          return self.current in self.finals

      self.stopped = True

    return False

  def reset (self) -> None:

    self.current = 0
    self.stopped = False

def Lexer (feed: Iterable[str]) -> Token:

  chars = [ ]
  position = 0

  rules = {
##
##  for name, rule in pairs (rules) do
##
##    local finals = assert (rule.finals)
##    local table = assert (rule.transitions)
##
    'f"name"' : LexerRule ([
##
##    for _, n in ipairs (finals) do
        f"n",
##    end
    ], {
##
##    for to, transitions in pairs (table) do
        f"to" : [
##      for _, transition in ipairs (transitions) do
##
##        local value, type_, negated = over.deserialize (transition.over)
##        local equalto = not negated and 'True' or 'False'
##
##        if (type_ == 'literal') then
##
            Transition (lambda char: (ord (char) == f"string.byte (value)") == f"equalto", f"transition.to"),
##        else
##
##          local lower = assert (value.lower):byte ()
##          local upper = assert (value.upper):byte ()
##
            Transition (lambda char: (ord (char) >= f"lower" and f"upper" >= ord (char)) == f"equalto", f"transition.to"),
##        end
##      end
    ],
##    end
      }),
##  end
  }

  feed = iter (feed)
  states = { name: False for name in rules.keys () }

  while True:

    try:

      chunk = next (feed)
      last = False

    except StopIteration as e:

      chunk = [ False ]
      last = True

    for char in chunk:

      position = position + 1

      while True:

        running = False

        if not last:

          transited = { name: rule.feed (char) for name, rule in rules.items () }

        for _, rule in rules.items ():

          if (not rule.stopped):

            running = True
            break

        if running and not last:

          chars.append (char)

          states = transited
          break

        else:

          gotcha = False

          for name, final in states.items ():

            if (final):

              gotcha = True
              states = { name: False for name in rules.keys () }
              value = ''.join (chars)

              for _, rule in rules.items (): rule.reset ()

              chars.clear ()

              yield Token (type = name, value = value)
              break

          if not gotcha:

            raise LexerException (position, ''.join (chars))

          if last: break

    if last: break

  if (len (chars) > 0):

    raise LexerException (position, ''.join (chars))
