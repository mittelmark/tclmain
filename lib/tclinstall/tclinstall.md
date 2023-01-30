---
title: Install Tcl packages 
author: Detlef Groth, Caputh-Schwielowsee
license: BSD 3
date: <230130.0716>
---

# NAME

`tclinstall` - installation of Tcl packages using setup.tcl files.

# DESCRIPTION

The Tcl application *tclinstall* installs Tcl packages into standard locations.
If the users then uses the application *tclmain* to start its Tcl scripts they
package should be automatically in the Tcl package path. The application requires
a file setup.tcl to to work reliable. In most cases however if given only a
directory name it should be as well possible to copy this directory into the
right folder. Package files can be as well in zip-archives where for the required
files, setup.tcl or pkgIndex.tcl is searched then automatically.. 

# USAGE

```
tclinstall setup.tcl
tclinstall . 
tclinstall folder
tclinstall package-main.zip
```

Or using `tclmain`

```
tclmain -m tclinstall setup.tcl
tclmain -m tclinstall .
```

# EXAMPLE SETUPFILE

Here a setup.tcl file:

```
# setup file for tclinstaller.tcl

array set setup {
  name kroki4tcl
  version 0.4.0
  url https://github.com/mittelmark/kroki4tcl
  author {Detlef Groth}
  license {BSD 3.0}
  include {kroki4tcl/*.tcl kroki4tcl/kroki4tcl.md}
}
```

If no `setup.tcl` is found the folder which contain pkgIndex.tcl files simply
will copied to the appropiate directories.


