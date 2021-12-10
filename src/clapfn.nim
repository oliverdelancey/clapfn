#[
clapfn v1.0.0

  Command
  Line
  Argument
  Parser
  For
  Nim

   author: Oliver Delancey
     date: 12/10/21
  license: MIT License
]#

import macros
import parseopt
import sequtils
import strutils
import system
import tables

type
  RequiredArgument = ref object of RootObj
    name: string
    value: string
    help: string

  StoreArgument = ref object of RootObj
    shortName: string
    longName: string
    usageInput: string
    value: string
    help: string

  SwitchArgument = ref object of RootObj
    shortName: string
    longName: string
    value: bool
    help: string

  ArgumentParser* = ref object of RootObj
    programName*: string
    fullName*: string
    author*: string
    description*: string
    version*: string
    requiredArgs: seq[RequiredArgument]
    storeArgs: Table[string, StoreArgument]
    switchArgs: Table[string, SwitchArgument]

proc removeDashes(s: string): string =
  var
    t = s
    i: int
  while true:
    i = t.find("-")
    if i == -1:
      break
    t.delete(i, i)
  return t

proc addRequiredArgument*(argparser: ArgumentParser, name: string,
    help: string) =
  let cla = RequiredArgument(name: name, help: help)
  argparser.requiredArgs.add(cla)

proc addStoreArgument*(argparser: ArgumentParser, shortName: string,
    longName: string, usageInput: string, default: string, help: string) =
  let cla = StoreArgument(shortName: shortName, longName: longName,
      usageInput: usageInput, value: default, help: help)
  argparser.storeArgs[removeDashes(shortName)] = cla
  argparser.storeArgs[removeDashes(longName)] = cla

proc addSwitchArgument*(argparser: ArgumentParser, shortName: string,
    longName: string, default: bool, help: string) =
  let cla = SwitchArgument(shortName: shortName, longName: longName,
      value: default, help: help)
  argparser.switchArgs[removeDashes(shortName)] = cla
  argparser.switchArgs[removeDashes(longName)] = cla

proc echoVersion(argparser: ArgumentParser) = # echo the version message
  echo argparser.fullName & " v" & argparser.version
  if not argparser.author.isEmptyOrWhitespace():
    echo argparser.author

proc echoUsage(argparser: ArgumentParser) = # echo the usage message
  var
    opts: seq[string]
    reqs: string

  # collect a sequence with the names of all optional arguments
  for arg in argparser.storeArgs.values:
    opts.add("[" & arg.shortName & "=" & arg.usageInput & "]")

  for arg in argparser.switchArgs.values:
    opts.add("[" & arg.shortName & "]")

  opts = deduplicate(opts)

  # collect a string with the name of all required arguments
  for _, arg in argparser.requiredArgs:
    reqs.add(" " & arg.name)

  # echo the usage message
  echo "Usage: " & argparser.programName & " [-h] [-v] " & opts.join(" ") & reqs

proc echoHelp(argparser: ArgumentParser) = # echo the help message
  var
    reqNameCol, reqDescCol, optNameCol, optDescCol, reqSec, optSec: seq[string]
    example, helpMessage: string
    maxNCLen: int
  const
    colMargin = 2
    tabSize = 4
  let
    tab = repeat(" ", tabSize)

  for i, arg in argparser.requiredArgs:
    reqNameCol.add(arg.name)
    reqDescCol.add(arg.help)
    if len(arg.name) > maxNCLen:
      maxNCLen = len(arg.name)

  # insert the help entry
  let helpargs = "-h, --help"
  optNameCol.add(helpargs)
  optDescCol.add("Show this help message and exit.")
  if len(helpargs) > maxNCLen:
    maxNCLen = len(helpargs)

  # insert the version entry
  let verargs = "-v, --version"
  optNameCol.add(verargs)
  optDescCol.add("Show version number and exit.")
  if len(verargs) > maxNCLen:
    maxNCLen = len(verargs)

  for arg in argparser.storeArgs.values:
    example = arg.shortName & "=" & arg.usageInput & ", " & arg.longName & "=" & arg.usageInput
    optNameCol.add(example)
    optDescCol.add(arg.help)
    if len(example) > maxNCLen:
      maxNCLen = len(example)
  for arg in argparser.switchArgs.values:
    example = arg.shortName & ", " & arg.longName
    optNameCol.add(example)
    optDescCol.add(arg.help)
    if len(example) > maxNCLen:
      maxNCLen = len(example)

  for _, lines in zip(reqNameCol, reqDescCol):
    reqSec.add(tab & lines[0] & repeat(" ", maxNCLen - len(lines[0]) +
        colMargin) & lines[1])
  for _, lines in zip(optNameCol, optDescCol):
    optSec.add(tab & lines[0] & repeat(" ", maxNCLen - len(lines[0]) +
        colMargin) & lines[1])
  reqSec = deduplicate(reqSec)
  optSec = deduplicate(optSec)

  helpMessage = "Required arguments:\n" & reqSec.join("\n") &
      "\n\nOptional arguments:\n" & optSec.join("\n")

  argparser.echoVersion()
  echo argparser.description
  echo ""
  argparser.echoUsage()
  echo ""
  echo helpMessage


proc parse*(argparser: ArgumentParser): Table[string, string] =

  macro badArg() =
    result = quote do:
      unRecArgs = true
      unRecArgsMsg.add(" " & iop.key)

  var
    iop = initOptParser()
    reqCount = 0
    unRecArgs = false
    unRecArgsMsg = "Error: unrecognized arguments:"

  while true:
    iop.next()
    case iop.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if iop.val == "": # if the cmd is only a flag
        case iop.key
        of "h", "help":
          argparser.echoHelp()
          quit(0)
        of "v", "version":
          argparser.echoVersion()
          quit(0)
        else:
          try:
            argparser.switchArgs[iop.key].value = true
          except KeyError:
            badArg()
      else:
        try:
          argparser.storeArgs[iop.key].value = iop.val
        except KeyError:
          badArg()
    of cmdArgument:
      try:
        argparser.requiredArgs[reqCount].value = iop.key
        reqCount += 1
      except IndexDefect:
        badArg()

  if reqCount < len(argparser.requiredArgs):
    var tooFewMsg = "Error: the following arguments are required:"
    for _, val in argparser.requiredArgs[reqCount..^1]:
      tooFewMsg.add(" " & val.name)
    argparser.echoUsage()
    echo tooFewMsg
    quit(1)

  if unRecArgs:
    argparser.echoUsage()
    echo unRecArgsMsg
    quit(1)

  var combined = initTable[string, string]()
  for _, arg in argparser.requiredArgs:
    combined[arg.name] = arg.value
  for name, arg in argparser.storeArgs.pairs:
    combined[name] = arg.value
  for name, arg in argparser.switchArgs.pairs:
    combined[name] = $arg.value

  return combined

