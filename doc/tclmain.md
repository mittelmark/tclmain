---
title: Tclmain - running Tcl applications directly from package folders
author: Detlef Groth, University of Potsdam, Germany
date: 2023-10-01 12:36
header-includes: 
- | 
    ```{=html}
    <style>
    body { max-width: 1000px; font-size: 120%; }
    pre { background: rgb(250,229,211); padding: 8px; }
    pre.sourceCode, pre.py { 
        background: #eeeeee; 
        padding: 8px;
        font-size: 95%;
    }
    .code-title {
      background: #dddddd;
      padding: 8px;
    } 
    </style>
    ```
kroki:
    cache: 0
    ext: "svg"
---

## Abstract 

The application tclmain allows the developer to embed Tcl application directly
within Tcl packages without the need to split application and package into two
different  folders.  Tcl  packages  can be made  applications  by  providing a
procedure `pkgname::main {{argv {}}} { code }` which can be then utilized with
the `tclmain`  application using the syntax `tclmain -p pkgname` directly from
the terminal.

## Introduction

Package developers  sometimes would like to target both Tcl developers and end
users to use the developed code. The Tcl developer usually utilize  procedures
or classes and their  methods  provided in the package  code whereas end users
utilizes often the package code directly using  applications,  either terminal application
or using graphical  interfaces. Until now the application and the package code
usually have to exists in two different files, the application code usually is
moved  to a  folder  belonging  to the  PATH  variable  and the  package  code
belonging  is moved the a folder  belonging to a path which is part of the Tcl
`auto_path` variable. Figure 1 illustrates this concept.

```{.kroki dia=plantuml echo=false}
digraph g {
    node[style="filled",fillcolor=salmon,shape=rect,height=0.7,width=1.2]
    Tclcode -> package -> lib
    Tclcode -> application -> bin
    bin[label="bin\nfolder"]
    lib[label="lib\nfolder"]
    bin -> app
    lib -> libcode 
    app[label="appcode.tcl"]
    libcode[label="pkgIndex.tcl\npkgcode.tcl"]

}
```

Since Tcl 8.5  version  the package  code can be as well  delivered  in as single
file with the extension `.tm`, as Tcl module thereby removing the necessity of
a pkgIndex.tcl  file, but still requiring the split of package and application
code.

Often Tcl developers add at the end of the package code a check if the package
is directly execute with the Tcl interpreter like this:

```{.tcl eval=true}
#!/usr/bin/env tclsh
package provide testx 0.0.1

## package code
namespace eval ::testx { }

proc ::testx::hello {name} {
    puts "Hello ${name}!"
}   

## application code
if {[info exists ::argv0] && [info script] eq $argv0} {
    if {[llength $argv] == 1} {
        ::testx::hello [lindex $argv 0]
    } else {
        puts "Usage: [info script] message"
    }
}   
```

If we run this file testx.tcl like this `tclsh testx.tcl` we get this:

```{.tcl echo=false eval=true}
puts "Usage: testx.tcl message"
```

If we run add an argument like this `tclsh testx.tcl hello` we get this:

```{.tcl echo=false eval=true}
puts "Hello hello!"
```

You can see, that we can  combine  package  code and  application  code easily
within  the same file.  However  to install  both  functionalities  we have to
create at least two  separate  files, one for the package code and one for the
application code where the first code goes into files in a folder belonging to
the Tcl library  paths, the latter, the  application  code, is going to a file
located in a folder belonging to the PATH variable. Although it would be still
possible to execute the file directly without this split, but only if the user
would know where in all the Tcl  library  folders is the  application  code is
located.

Python  programmers  can  avoid  this  split by  placing a file  `__main__.py`
directly within the package and placing the application code therein. The user
can then execute this file by writing  `python -m pkgname` in the terminal. To
given an  example  just call  `python3 -m pip` in your  terminal  and you have
access to the Python  package  manager. On my machine  currently are 80 Python
packages installed which provide these `__main__.py` files.


Aim: The goal of the tclmain  application  is to provide the Tcl package  code and
the application utilizing the package code within the package code itself. Users should
be then able to call the  application  even  without  an  installation  of the
application  code in folders belonging to the PATH  variable. The  application
should be then callable  using the syntax  `tclmain -m pkgname` or `tclmain -p
pkgname`.  Both the -m and the -p options should do the same thing and can be
seen as aliases for (m)odule and (p)ackage.

## Implementation

There are two possible  ways to add this  functionality  to your Tcl packages,
one is by providing  additional files in your package code folder which follow
the  `pkgname_main.tcl`  syntax, the other by  providing a Tcl  main-procedure
with argv as the only  possible  argument,  where the  default  for argv is an
empty  list.  

### The main procedure approach

Here an  example  how the  testx.tcl  file from  above  could be
modified to be callable directly or using tclmain.


```{.tcl eval=true echo=false}
package forget testx
```

```{.tcl eval=true}
#!/usr/bin/env tclsh
package provide testx 0.0.2

## package code
namespace eval ::testx { }

proc ::testx::hello {name} {
    puts "Hello ${name}!"
}   

## make it callable using tclmain -m pkgname
## the argument argv must be declared exactly like here
proc ::testx::main {{argv {}}} {
    if {[llength $argv] == 1} {
        ::testx::hello [lindex $argv 0]
    } else {
        puts "Usage: [info script] message"
    }
}   
## application code allowing to call the file still directly
## using tclsh testx.tcl args ... syntax
if {[info exists ::argv0] && [info script] eq $argv0} {
    ::testx::main $argv
}   
```

The  advantage of this approach is that the developer has not to create a new
file, the file can be still called  directly  using `tclsh  pkgname.tcl  args`
syntax as well after  installation using the `tclmain -m pkgname args` syntax.
An other  advantage is that the main  procedure is now part of the package and
can be documented  within the package as well and can be as well utilized from
other Tcl code  directly by calling the main  function  with the argv list or
with other, developer created lists.

The  disadvantage of this approach is that  without  loading  the  package the Tcl
interpreter  would not know exactly  which of all the packages  provides  this
functionality. You could for instance just search for all file which ends with
`_main.tcl` to find the Tcl applications within package.

### The main file approach

This file based approach places the application  code within the package folder but into a
separate file which has the filename prefix of the package followed by an underline and
then a short lowercase  string usually main, but as well other short names such
as help, api etc are possible.

For our testx example we could then just create a file  `testx_main.tcl`  with
the following content:

```{.tcl}
### file testx_main.tcl
package require testx
testx::main $argv
```

We could as well  remove  the main  function  from the  package  and place the
application code directly here. I would however prefer to keep the application
code  short and keep the main  procedure  as part of the  package  and not the
application.

The main-file approach has the advantage that even without loading the package
code and checking for the presence of a `pkgname::main`  procedure with the empty
argv  argument as default we can check for the  existence  of these  underline
files and know which  packages  would be  executable  via the the  `tclmain -m pkgname` call syntax.

## Installation of tclmain

The Tcl script is a single file which can be downloaded  directly from Github.
The  following   example  would  install  the  script  into  a  users  PATH  -
`~/.local/bin`

```
wget https://raw.githubusercontent.com/mittelmark/tclmain/main/bin/tclmain.tcl
mv tclmain.tcl tclmain
chmod 755 tclmain
mv tclmain ~/.local/bin
```

You could then check if the  application is installed by writing  `tclmain -h`
on the terminal.

## Summary

The tclmain  application  simplifies  distribution of Tcl  applications  still
being part of packages,  without  the need to install  additional  application  code
within folders  belonging to the users PATH variable. If the users can install
the package he has the application callable via `tclmain -p pkgname`.

