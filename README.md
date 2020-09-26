# clapfn

`clapfn` is a straightforward, easy-to-use **C**ommand **L**ine **A**rgument **P**arser **F**or **N**im.

## Usage

`clapfn` is specifically designed to be straightforward to work with.
```nim
import tables
import clapfn

var parser = ArgumentParser(programName: "mcp", fullName: "My Cool Program", description: "A test program.", version: "0.0.0")

# See the wiki for in-depth documentation, especially the purposes of the various parameters.

parser.addRequiredArgument("in_file", "Input file.")
parser.addStoreArgument("-o", "--out", "output", "out.file", "Specify the output file.")
parser.addSwitchArgument("-d", "--debug", false, "Enable debug printing.")

let args = parser.parse()

echo args["in_file"]
echo args["out"]
echo args["debug"]
```

And if you were to run `mcp --help`:
```
My Cool Program v0.0.0
A test program.

Usage: mcp [-h] [-o output] [-d] in_file

Required arguments:
    in_file                  Input file.

Optional arguments:
    -h, --help               Show this help message and exit.
    -o output, --out output  Specify the output file.
    -d, --debug              Enable debug printing.
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
