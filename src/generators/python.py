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
from collections import namedtuple, OrderedDict
from typing import Dict, Iterable, List, ClassVar

Transition = namedtuple ('Transition', [ 'factible', 'to' ])

class Token ():
##
##  for name, rule in require ('pl.OrderedMap').iter (rules) do
##
  f"name": ClassVar[str] = 'f"name"'
##  end
##

  column: int
  line: int
  type: str
  value: str

  def __init__ (self, column, line, type: str, value: str):

    self.column = column
    self.line = line
    self.type = type
    self.value = value

def Lexer (feed: Iterable[str]) -> Token:

  chars = [ ]

  rules = OrderedDict ([
##
##  for name, rule in require ('pl.OrderedMap').iter (rules) do
##
##    local finals = assert (rule.finals)
##    local table = assert (rule.transitions)
##
    ('f"name"',  LexerRule ([ f"List.reduce (finals, function (a, e) return ('%s, %d'):format (tostring (a), e) end)" ],
      {
##
##    for to, transitions in pairs (table) do
        f"to" : [
##
##      for _, transition in ipairs (transitions) do
##
##        if (transition.over == true) then
##
            Transition (lambda char: True, f"transition.to"),
##        else
##
##          local value, type_, negated = over.deserialize (transition.over)
##          local equalto = not negated and 'True' or 'False'
##
##          if (type_ == 'literal') then
##
              Transition (lambda char: f"equalto" == (ord (char) == f"string.byte (value)"), f"transition.to"),
##          else
## 
##            local lower = assert (value.lower):byte ()
##            local upper = assert (value.upper):byte ()
##
              Transition (lambda char: f"equalto" == (ord (char) >= f"lower" and f"upper" >= ord (char)), f"transition.to"),
##          end
##        end
##      end
        ],
##    end
      })),
##  end
  ])

  ncolumn = 0
  nline = 1

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

      ncolumn = ncolumn + 1

      if (char == '\n'):

        nline = nline + 1
        ncolumn = 1

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

              yield Token (ncolumn - len (value), nline, name, value)
              break

          if not gotcha:

            value = ''.join (chars)
            value = value if len (chars) > 0 else char + value

            raise LexerException (ncolumn - len (value), nline, value)

          if last: break

    if last: break

  if (len (chars) > 0):

    raise LexerException (ncolumn - len (value), nline, ''.join (chars))

class LexerException (Exception):

  column: int
  line: int
  value: str

  def __init__ (self, column, line, value) -> None:

    super ().__init__ ()

    self.column = column
    self.line = line
    self.value = value.replace ('\n', '\\n').replace ('\r', '\\r')

  def __str__ (self) -> str:

    return f'{self.line}: {self.column}: unknown token \'{self.value}\''

class LexerRule:

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
