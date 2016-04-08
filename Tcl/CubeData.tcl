#
# $Header: /opt/cvs-repository/cubes/CubeData.tcl,v 1.14 2004/04/09 02:25:44 Robert Exp $
#

package require Itcl

# Types of cubes:
# color:(red|blue|green|yellow|purple)
# mult:(2|3|4)
# span:1

itcl::class CubeData {
    private variable data {}
    private variable window ""

    public constructor {{nData {}}} {
        set data {}
        foreach row $nData {
            set newRow {}
            foreach elem $row {
                lappend newRow $elem
            }
            lappend data $newRow
        }
    }

    public method getData {} {
        return $data
    }

    public method setWindow {win} {
        set window win
    }

    protected method updateWindow {} {
        if {[string length $window]} {
            $window drawData $data
        }
    }

    public method siftDown {} {
        set width [llength [lindex $data 0]]
        set height [llength $data]

        set modified 0
        for {set w 0} {$w < $width} {incr w} {
            for {set h 1} {$h < $height} {incr h} {
                if {![llength [lindex $data $h $w]] &&
                    [llength [lindex $data [expr {$h -1}] $w]]} {
                    set modified 1
                    set l1 [lindex $data $h]
                    set l2 [lindex $data [expr {$h - 1}]]
                    set l1 [lreplace $l1 $w $w [lindex $l2 $w]]
                    set l2 [lreplace $l2 $w $w {}]
                    set data [lreplace $data [expr {$h - 1}] $h $l2 $l1]
                }
            }
        }
        set modified
    }

    public method siftLeft {} {
        set output {}

        set modified 0
        foreach row $data {
            for {set i [expr {[llength $row]-1}]} {$i >= 0} {incr i -1} {
                if { ![string length [lindex $row $i]] &&
                     [string length [lindex $row [expr {$i +1}]]]} {
                    set modified 1
                    set row [lreplace $row $i $i]
                    lappend row {}
                }
            }
            lappend output $row
        }

        set data $output
        set modified
    }

    public method getNeighbors {y x} {
        set width [llength [lindex $data 0]]
        set height [llength $data]

        set result {}
        foreach {ix iy} {-1 0 1 0 0 -1 0 1} {
            set nx [expr {$x + $ix}]
            set ny [expr {$y + $iy}]
            if { ($nx >= 0) && ($nx < $width) && ($ny >= 0) && ($ny < $height) } {
                lappend result [list $ny $nx]
            }
        }

        set result
    }

    public method getFullConnected {y x {curList {}}} {
        set retval {}

        set baseValue [lindex [lindex $data $y] $x]
        foreach neigh [getNeighbors $y $x] {
            foreach {ny nx} $neigh {break}
            set nValue [lindex [lindex $data $ny] $nx]
            if { [lsearch $curList [list $ny $nx $nValue]] >= 0} {
                continue
            }

            if {[isConnected $baseValue $nValue]} {
                lappend curList [list $ny $nx $nValue]
                lappend retval [list $ny $nx $nValue]
                foreach entry [getFullConnected $ny $nx $curList] {
                    if { [lsearch $curList $entry] < 0} {
                        lappend curList $entry
                        lappend retval $entry
                    }
                }
            }
        }
        set retval
    }
    
    public method getCloseConnected {color startList} {
        set retval {}
        foreach entry $startList {
            foreach {y x value} $entry {break}
            foreach neighbor [getNeighbors $y $x] {
                foreach {ny nx} $neighbor {break}
                set ntype [lindex $data $ny $nx]
                set elem [list $ny $nx $ntype]
                if {([isLike color:* $ntype] || [isLike mult:* $ntype]) &&
                    [lsearch $startList $elem] < 0 &&
                    [lsearch $retval $elem] < 0} {
                    lappend retval $elem
                }
            }
        }
        set retval
    }
    
    public proc isLike {c1 c2} {
        string match $c1 $c2
    }

    public proc containsElement {type elList} {
        foreach elem $elList {
            foreach {y x elType} $elem {break}
            if {[isLike $type $elType]} {
                return 1
            }
        }
        return 0
    }

    public proc countScore {listOne {listTwo {}}} {
        set multiple 1
        set score 0
#       puts "list 1 = $listOne"
#       puts "list 2 = $listTwo"
        foreach elem $listOne {
            foreach {y x type} $elem {break}
            if { [isLike "color:*" $type] } {
                incr score
            }
            if { [isLike "mult:*" $type] } {
                scan $type "mult:%d" mult
                set multiple [expr {$multiple * $mult}]
#               puts "Multipler was $mult -> total multipler is $multiple"
            }
        }
        foreach elem $listTwo {
            foreach {y x type} $elem {break}
            if { [isLike "color:*" $type] } {
                incr score
            }
            if { [isLike "mult:*" $type] } {
                scan $type "mult:%d" mult
                set multiple [expr {$multiple * $mult}]
            }
        }
        set score [expr {$score * $multiple}]
    }

    public method getElement {y x} {
        lindex $data $y $x
    }

    public method height {} {
        llength $data
    }

    public method width {} {
        llength [lindex $data 0]
    }

    public method clicked {y x} {}
    public method removeElements {elList} {}
    public proc isConnected {type1 type2} {}
    public method populate {height width}
    public method hasMoves {}
    public method numCubes {}
    public method ifClicked {y x}
}

itcl::body CubeData::clicked {y x} {
    set color [lindex $data $y $x]
    set cubeList [getFullConnected $y $x]
    set count 0
    foreach cube $cubeList {
        if {[isLike color:* [lindex $cube 2]]} {
            incr count
        }
    }
    if {$count <= 1} {
        return 0
    }
    if { [containsElement span:* $cubeList] } {
        set moreCubes [getCloseConnected $color $cubeList]
        puts "Contained a span... adding [llength $moreCubes] more cubes"
    } else {
        set moreCubes {}
    }

    set score [countScore $cubeList $moreCubes]
    removeElements $cubeList
    removeElements $moreCubes

    return $score
}

itcl::body CubeData::ifClicked {y x} {
    set color [lindex $data $y $x]
    set cubeList [getFullConnected $y $x]
    set count 0
    foreach cube $cubeList {
        if {[isLike color:* [lindex $cube 2]]} {
            incr count
        }
    }
    if {$count <= 1} {
        return [list [list $y $x [getElement $y $x]]]
    }
    if { [containsElement span:* $cubeList] } {
        set moreCubes [getCloseConnected $color $cubeList]
    } else {
        set moreCubes {}
    }

    foreach elem $moreCubes {
        lappend cubeList $elem
    }

    return $cubeList
}

itcl::body CubeData::removeElements {elList} {
    set height [llength $data]
    for {set i 0} {$i < $height} {incr i} {
        set row$i [lindex $data $i]
    }
    foreach elem $elList {
        foreach {y x} $elem {break}
        set row$y [lreplace [set row$y] $x $x {}]
    }
    set data {}
    for {set i 0} {$i < $height} {incr i} {
        lappend data [set row$i]
    }
}

itcl::body CubeData::isConnected {type1 type2} {
    if { [isLike color:* $type1] && [isLike color:* $type2] } {
        return [isLike $type1 $type2]
    }
    if { [isLike color:* $type1] && ![isLike color:* $type2] } {
        return 1
    }
    return 0
}

itcl::body CubeData::populate {height width} {
    set data {}
    for {set i 0} {$i < $height} {incr i} {
        set row {}
        for {set j 0} {$j < $width} {incr j} {
            set rand [expr {rand()}]
            if { $rand < .25 } {
                set color blue
            } elseif { $rand < .50 } {
                set color red 
            } elseif { $rand < .75 } {
                set color purple 
            } else {
                set color yellow
            }
            set rand [expr {rand()}]
            if { $rand < .96 } {
                lappend row "color:$color"
            } elseif { $rand < .98 } {
                lappend row "mult:2"
            } elseif { $rand < .99 } {
                lappend row "mult:3"
            } else {
                lappend row "span:1"
            }
        }
        lappend data $row
    }
}

itcl::body CubeData::hasMoves {} {
    set height [llength $data]
    set width [llength [lindex $data 0]]
    for {set i 0} {$i < $height} {incr i} {
        for {set j 0} {$j < $width} {incr j} {
            set type [lindex $data $i $j]
            if {![isLike color:* $type]} {
                continue
            }
            foreach neighbor [getNeighbors $i $j] {
                foreach {ny nx} $neighbor {break}
                set nType [lindex $data $ny $nx]
                if {[isLike $type $nType]} {
                    return 1
                }
            }
        }
    }
    return 0
}

itcl::body CubeData::numCubes {} {
    set retval 0
    foreach row $data {
        foreach elem $row {
            incr retval [isLike color:* $elem]
        }
    }
    set retval
}
