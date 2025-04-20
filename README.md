# fixpath

This tool will fix directory trees and filenames that contain
chars with awkward/bad/non-portable chars.

Sometimes one encounters filenames that contain spaces, tabs,
newlines, leading -'s, #'s, quotes, non-printable chars, etc.
Such files are sometimes awkward to types and manipulate on
the command line.  The fixpath tool will rename those files to
'nicer' names.


# To install

```sh
sudo make install
```


# To use

```
/usr/local/bin/fixpath [-h] [-v lvl] [-V] file ...

    -h          print help and exit
    -v lvl      verbose / debug level
    -V          print version and exit

    -n          go thru the actions, but do not update any files (def: do the action)
    -N          do not process anything, just parse arguments (def: process something)

    -s          strict POSIX chars only
    -i          ignore %'s if followed by 2 hex chars

    file ...    file paths to fix

fixpath version: 1.7.1 2025-04-05
```

When fixpath encounters an awkward char in a filename, it
renames that file using the %xx notation where 'xx' is the
hex value of the original character.  See man ASCII for a
complete list.

For example a directory named "Program Files" will be renamed
Program%20Files by fixpath because ASCII space is hex 0x20.

By default, fixpath silently fixes files under dir.  Use the `-v 1` option:

```sh
$ /usr/local/bin/fixpath -v 1 some_path
```

to watch what is is doing.

You can look first, but NOT modify by giving the -n option.
Of course, to see anything you also need the `-v 1` option.

To see what awkward chars might exist under a directory tree
but NOT modify/rename anything (look but do not touch mode), use `-n`:

```sh
$ /usr/local/bin/fixpath -n -v 1 some_path
```

Technically the % character is not part of the official
portable character set.  However if a tree has been
processed by fixpath, it will contain names with %'s in them.
Running fixpath over that SAME tree again will convert all
%'s into %25 renaming the already renamed Program%20Files
into Program%2520Files.  To avoid this, use the `-i` (ignore
%'s if followed by 2 hex chars).  So:

```sh
$ /usr/local/bin/fixpath -v 1 -i some_path
```

will fix all but %'s and:

```sh
$ /usr/local/bin/fixpath -n -v 1 -i some_path
```

will check (but not fix) all awkward chars except %'s
(followed by 2 hex chars).

Finally, the `-s` forces one into a strict POSIX char set.
The POSIX portable char set is more restrictive than the
common char set.  So:

fixpath -v -s some_dir
```sh
$ /usr/local/bin/fixpath -v 1 -s some_path
```

will be really strict about awkward chars.	Generally the
`-s` strict POSIX char set mode it not needed.


# Reporting Security Issues

To report a security issue, please visit "[Reporting Security Issues](https://github.com/lcn2/fixpath/security/policy)".
