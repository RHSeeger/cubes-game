#
# $Header: /opt/cvs-repository/cubes/drawing.tcl,v 1.4 2004/04/13 02:00:52 Robert Exp $
#

package require Tk

namespace eval drawing {
    variable MAX_INTENSITY 65535
}

proc drawing::shadow.dark {R G B} {
    variable MAX_INTENSITY
    if { [expr {($R*0.5*$R) + ($G*1.0*$G) + ($B*0.28*$B)}] <
         [expr {$MAX_INTENSITY*0.05*$MAX_INTENSITY}] } {
        set r [expr {($MAX_INTENSITY + 3*$R)/4}]
        set g [expr {($MAX_INTENSITY + 3*$G)/4}]
        set b [expr {($MAX_INTENSITY + 3*$B)/4}]
    } else {
        set r [expr {(60 * $R)/100}]
        set g [expr {(60 * $G)/100}]
        set b [expr {(60 * $B)/100}]
    }
    return [format \#%04X%04X%04X $r $g $b]
}

proc drawing::shadow.light {R G B} {
    variable MAX_INTENSITY

    if { $G > [expr {$MAX_INTENSITY*0.95}] } {
        set r [expr {(90 * $R)/100}]
        set g [expr {(90 * $G)/100}]
        set b [expr {(90 * $B)/100}]
    } else {
        set tmp1 [expr {(14 * $R)/10}]

        if { $tmp1 > $MAX_INTENSITY } { set tmp1 $MAX_INTENSITY }

        set tmp2 [expr {($MAX_INTENSITY + $R)/2}]
        set r    [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
        set tmp1 [expr {(14 * $G)/10}]

        if { $tmp1 > $MAX_INTENSITY } { set tmp1 $MAX_INTENSITY }

        set tmp2 [expr {($MAX_INTENSITY + $G)/2}]
        set g    [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
        set tmp1 [expr {(14 * $B)/10}]

        if { $tmp1 > $MAX_INTENSITY } { set tmp1 $MAX_INTENSITY }

        set tmp2 [expr {($MAX_INTENSITY + $B)/2}]
        set b    [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
    }

    return [format \#%04X%04X%04X $r $g $b]

}

proc drawing::rect {c x1 y1 x2 y2 bd color {text ""}} {
    set dark  [eval shadow.dark  [winfo rgb $c $color]]
    set light [eval shadow.light [winfo rgb $c $color]]
    
    set itemList {}
    lappend itemList [$c create polygon \
                          $x1 $y1 \
                          $x2 $y1 \
                          [expr {$x2 - $bd}] [expr {$y1 + $bd}] \
                          [expr {$x1 + $bd}] [expr {$y1 + $bd}] \
                          [expr {$x1 + $bd}] [expr {$y2 - $bd}] \
                          $x1 $y2 \
                          -fill    $light \
                          -outline $light]

    lappend itemList [$c create polygon \
                          $x2 $y1 \
                          $x2 $y2 \
                          $x1 $y2 \
                          [expr {$x1 + $bd}] [expr {$y2 - $bd}] \
                          [expr {$x2 - $bd}] [expr {$y2 - $bd}] \
                          [expr {$x2 - $bd}] [expr {$y1 + $bd}] \
                          -fill    $dark \
                          -outline $dark]

    lappend itemList [$c create rectangle \
                          [expr {$x1 + $bd}] [expr {$y1 + $bd}] \
                          [expr {$x2 - $bd}] [expr {$y2 - $bd}] \
                          -fill    $color \
                          -outline $color]

    if {[string length $text]} {
        lappend itemList [$c create text \
                              [expr {($x1 + $x2)/2}] [expr {($y1 + $y2)/2}] \
                              -anchor center -text $text]
    }
    
    set itemList
}

