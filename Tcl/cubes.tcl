#!/bin/sh
# This line continues for Tcl, but is a single line for 'sh' \
        exec tclsh "$0" ${1+"$@"}

#
# $Header: /opt/cvs-repository/cubes/cubes.tcl,v 1.11 2004/04/12 01:29:08 Robert Exp $
#

package require -exact Itcl 3.2
package require -exact Itk 3.2
package require Iwidgets

foreach elem {
    CubeData.tcl
    CubeWindow.tcl
    CubeScores.tcl
    CubeScoresWindow.tcl
    CanvasSection.tcl
    drawing.tcl
} {
    source [file join [file dirname [info script]] $elem]
}

set dataObject [CubeData  \#auto {}]
$dataObject populate 12 12
CubeWindow .cube -dataobject $dataObject

pack .cube -expand 1 -fill both
wm resizable . 0 0

package provide app-cubes 1.0
