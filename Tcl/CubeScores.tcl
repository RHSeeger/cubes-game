#
# $Header: /opt/cvs-repository/cubes/CubeScores.tcl,v 1.1 2004/04/10 22:15:11 Robert Exp $
#

package require Itcl

itcl::class CubeScores {
    protected variable scoreList {}

    public constructor {} {
        for {set i 0} {$i < 10} {incr i} {
            lappend scoreList {0 0 0}
        }
    }

    public method loadScores {{filename {}}} {
        if {![string length $filename]} {
            set filename [file join [file dirname [info script]] scores.txt]
        }

        set newscores {}
        set count 0

        if { [file exists $filename] } {
            set fd [open $filename r]
            while { [gets $fd line] >= 0} {
                set data [split $line]
                lappend newscores $data
                incr count
            }
            close $fd
        }

        for {set i 10} {$i > $count} {incr i -1} {
            lappend newscores {0 0 0}
        }

        set scoreList $newscores

        return $count
    }

    public method getScores {} {
        return $scoreList
    }

    public method addScore {score level time} {
        lappend scoreList [list $score $level $time]
        set scoreList [lsort -index 0 -decreasing -integer $scoreList]
        if {[llength $scoreList] >10} {
            set scoreList [lrange $scoreList 0 9]
        }
    }

    public method saveScores {{filename {}}} {
        if {![string length $filename]} {
            set filename [file join [file dirname [info script]] scores.txt]
        }
        set fd [open $filename w]
        foreach elem $scoreList {
            puts $fd [join $elem]
        }
        close $fd
    }

    public proc loadAddSaveScore {score level time {filename {}}} {
        set obj [CubeScores \#auto]
        $obj loadScores $filename
        $obj addScore $score $level $time
        $obj saveScores $filename
    }
}
