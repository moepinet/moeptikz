moepTikZ - a library for typesetting computer networks
======================================================
Version 1.1, 2026/11/15

Overview
--------
The moepTikZ package provides TikZ shapes for typesetting computer networks,
e.g. shapes for hubs, switches, routers, and more.  It has been in use since
2012 for the lecture materials of an introductory course in computer networks
due to shortcomings of some commercial products and (at that time) the lack of
meaningful alternatives.

The package currently provides the following shapes, styles and commands:

  * `hub`, `switch`, `mlswitch` (multilayer switch), `router`, `fwrouter`
    (router with firewall), `fw` (firewall), `nuc` (alias `ap`), `modem`,
    `wlanmodem`
  * `client`, `notebook`, `smartphone`, `server`, `rack`, `db` (database),
    `internet`
  * `user`, `usergroup`, `messageclosed`, `messageopen`, `key`, `keyhole`
  * `waves` (wireless links)
  * `\tikzextractx`, `\tikzextracty`, `\moeptikzset`

Like ordinary TikZ nodes, the shapes have compass and angle anchors; the
compass anchors lie on the outline in their direction, e.g. `north east` is
the same point as the angle anchor `45` (`internet` keeps the anchors of
PGF's `cloud`).  The anchor `base` lies on the baseline of the node text and
`mid` .5ex above it, with east and west variants as for TikZ's `rectangle`;
a matrix of nodes aligns the texts.

`fill=<color>` changes the color of a shape and `minimum size=<length>` its
size; `draw=<color>` changes the arrows of `hub`, `switch`, `mlswitch`,
`router` and `fwrouter` and the lines of `messageopen`, `messageclosed` and
`internet`.  The shape names take no value: put these options after the
shape name, as in `\node[router,minimum size=2cm,fill=red]`; in front of
it, the defaults of the shape may override them.


Requirements
------------
moepTikZ needs LaTeX 2020-10-01 or newer and TikZ.  It loads keyval, tikz and
the TikZ libraries shapes.symbols and decorations.markings by itself.  It is
tested with TeX Live 2026 (PGF 3.1.11a) and works with pdfLaTeX, XeLaTeX and
LuaLaTeX.


Installation
------------
The package is the single file `moeptikz.sty`.  If your TeX distribution does
not provide it, copy it next to your document or into your personal texmf
tree, e.g. `TEXMFHOME/tex/latex/moeptikz/` (`kpsewhich -var-value TEXMFHOME`
shows where `TEXMFHOME` is), and load it with

    \usepackage{moeptikz}

By default the nodes are shaded; the package option `noshading` fills them
with a flat color instead.


Usage
-----
    \documentclass{article}
    \usepackage{moeptikz}
    \begin{document}
    \begin{tikzpicture}
      \node[client]   (c) at (0,0)   {PC};
      \node[switch]   (s) at (2.5,0) {Switch};
      \node[router]   (r) at (5,0)   {Router};
      \node[internet] (i) at (8,0)   {Internet};
      \draw (c) -- (s) -- (r) -- (i);
    \end{tikzpicture}
    \end{document}

The node text appears below the shape, or inside the cloud for `internet`.


Known incompatibilities
-----------------------
Some keys of moepTikZ have the names of keys or shapes of other packages,
and only one of them can take effect; moepTikZ warns about these clashes at
`\begin{document}`.

  * circuitikz defines the key `switch` (a switch in a circuit) and the
    shape `waves`.  Whichever of moepTikZ and circuitikz is loaded last wins
    the key `switch`; with moepTikZ loaded last, `to[closing switch]` still
    draws the switch of circuitikz.  circuitikz's option `compatibility`
    avoids this clash: its switch is then `*switch`.  The path style `waves`
    of moepTikZ hides the shape `waves` of circuitikz; write `shape=waves`
    for the latter.
  * tikz-feynman and the graph drawing library of TikZ use the key
    `horizontal`, as in `horizontal=a to b`: write
    `/graph drawing/horizontal=a to b` in the options of a picture, scope or
    diagram, and `/tikz/horizontal` for a firewall inside `\graph` (see the
    section on firewalls in the documentation).  Without LuaTeX (pdfLaTeX,
    XeLaTeX, latex with dvips), load tikz-feynman before moepTikZ; otherwise
    `horizontal` only warns that it needs LuaTeX.

To hide the warnings, load the silence package and write
`\WarningsOff[moeptikz]`.


Documentation
-------------
The file `moeptikz-doc.pdf` shows all shapes and explains the options and
commands; `texdoc moeptikz` opens it if your TeX distribution provides
moepTikZ.  To rebuild it from `moeptikz-doc.tex`, run

    make

in the package directory (the auxiliary files go to `build/`; `make fresh`
rebuilds everything from scratch), or run `pdflatex moeptikz-doc.tex` twice.
Besides moepTikZ the documentation uses KOMA-Script, geometry, siunitx and
inconsolata.


Changes
-------

### Version 1.1

  * Shadings now respect beamer's covered overlays: with
    `\setbeamercovered{transparent}`, covered nodes and the arrows of hub,
    switch, mlswitch, router and fwrouter fade like other covered material;
    before, the first use of a color decided for all nodes of that color.
  * `paper color` of `messageopen` also takes color expressions such as
    `red!60`.
  * `notebook` is drawn about six times faster.
  * moepTikZ warns at `\begin{document}` about key clashes with circuitikz
    (`switch`, `waves`), tikz-feynman and the graph drawing library of TikZ
    (`horizontal`); see "Known incompatibilities" above.
  * The documentation is now `moeptikz-doc.pdf`, named after the package as
    CTAN recommends, and the README is now `README.md`.

### Version 1.0

Documents written for the earlier versions without a version number may need
small changes:

  * The compass anchors (`north`, `north east`, ...) of `server`, `client`,
    `hub`, `switch`, `mlswitch`, `router`, `fwrouter`, `nuc`, `ap` and
    `messageclosed` now lie on the outline like those of the other shapes.
    Nodes placed with these anchors, with `anchor=`, positioning
    (`above=of`, ...) or `fit` may move by a few points.
  * The shape names take no value: write `server,minimum size=2cm,fill=red`
    instead of `server={2cm}{red}`, and `router,fill=red,draw=blue` instead
    of `router={1cm,red,blue}`.
  * The TikZ keys `get stroke color` and `replace fill by stroke color` are
    gone; they were meant for internal use.


Bug reports and feature requests
--------------------------------
Both are highly welcome.  Please open an issue at
<https://github.com/moepinet/moeptikz/issues> or write to <moepi@moepi.net>,
and mention the version from the line `Package: moeptikz ...` in the log
file of your document.


License
-------
Copyright 2015-2026 Stephan M. Günther

moepTikZ may be distributed and/or modified under the conditions of the LaTeX
Project Public License (LPPL), either version 1.3c of this license or (at your
option) any later version.  The file `LICENSE` contains version 1.3c; the
latest version is at <https://www.latex-project.org/lppl.txt>.

The work consists of the files `moeptikz.sty`, `moeptikz-doc.tex`,
`README.md` and `Makefile` and the derived file `moeptikz-doc.pdf`.  It has
the LPPL maintenance status "maintained"; the Current Maintainer is
Stephan M. Günther.
