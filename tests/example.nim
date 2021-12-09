import tables
import clapfn

var parser = ArgumentParser(programName: "mcp", fullName: "My Cool Program",
                            description: "A test program.", version: "0.0.0",
                            author: "An Author <author@domain.com>")

# See the wiki for in-depth documentation, especially the purposes
# of the various parameters.

parser.addRequiredArgument("in_file", "Input file.")
parser.addStoreArgument("-o", "--out", "output", "out.file",
                        "Specify the output file.")
parser.addSwitchArgument("-d", "--debug", false, "Enable debug printing.")

let args = parser.parse()

echo args["in_file"]
echo args["out"]
echo args["debug"]
