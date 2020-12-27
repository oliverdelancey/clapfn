# clapfn

[![Language](https://img.shields.io/badge/language-nim-yellow?style=flat-square&logo=nim")](https://nim-lang.org/)
[![Nimble](https://img.shields.io/badge/nimble%20repo-clapfn-yellowgreen?style=flat-square&")](https://nimble.directory/pkg/clapfn)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square&logo=github")](https://github.com/oliversandli/clapfn/blob/master/LICENSE")

`clapfn` is an easy-to-use **C**ommand **L**ine **A**rgument **P**arser **F**or **N**im.

## Installation

Installing is as simple as:
```bash
nimble install clapfn
```

## Usage

`clapfn` is specifically designed to be straightforward to work with.
```nim
import tables
import clapfn

var parser = ArgumentParser(programName: "mcp", fullName: "My Cool Program",
                            description: "A test program.", version: "0.0.0")

# See the wiki for in-depth documentation, especially the purposes
# of the various parameters.

# It is not necessary to use the argument names; they are here
# simply for explanation. *All* function arguments are required.
parser.addRequiredArgument(name="in_file", help="Input file.")
parser.addStoreArgument(shortName="-o", longName="--out", usageInput="output",
                        default="out.file", help="Specify the output file.")
parser.addSwitchArgument(shortName="-d", longName="--debug", default=false,
                         help="Enable debug printing.")

let args = parser.parse()

echo args["in_file"]
echo args["out"]
echo args["debug"]
```

And if you were to run `mcp --help`:
```
My Cool Program v0.0.0
A test program.

Usage: mcp [-h] [-v] [-o output] [-d] in_file

Required arguments:
    in_file                  Input file.

Optional arguments:
    -h, --help               Show this help message and exit.
    -v, --version            Show version number and exit.
    -o=output, --out=output  Specify the output file.
    -d, --debug              Enable debug printing.
```

`clapfn` uses Nim's default delimiter style:
```bash
# good
-o:output
-o=output

# BAD
-o output
```

The values of the command line arguments are stored in a [Table](https://nim-lang.org/docs/tables.html), and can be accessed thus:
```nim
args["in_file"]
args["out"]
args["debug"]
# etc
```

See `example.nim` for a fully functional example.

## Documentation

See the [wiki](https://github.com/oliversandli/clapfn/wiki) for documentation.

## License

This project uses the [MIT License](https://github.com/oliversandli/clapfn/blob/master/LICENSE)

## Contact

Raise an Issue! I'll see you there.

Project link: [https://github.com/oliversandli/clapfn](https://github.com/oliversandli/clapfn)
