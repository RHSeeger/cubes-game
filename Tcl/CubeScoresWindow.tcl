#
# $Header: /opt/cvs-repository/cubes/CubeScoresWindow.tcl,v 1.1 2004/04/11 06:01:39 Robert Exp $
#

package require Itk
package require Iwidgets

itcl::class CubeScoresWindow {
    inherit itk::Widget

    public variable filename \
        [file join [file dirname [info script]] scores.txt]

    constructor {parent args} {
        itk_component add canvas {
            canvas $itk_interior.canvas
        }

        itk_component add buttonbar {
            frame $itk_interior.buttonbar
        }

        itk_component add buttonok {
            button $itk_component(buttonbar).buttonok \
                -text Ok -command [list $parent doneScores]
        }

        itk_component add buttonclear {
            button $itk_component(buttonbar).buttonclear \
                -text Clear -command {puts Clear}
        }

        pack $itk_component(buttonok) -expand true -fill both -side left
        pack $itk_component(buttonclear) -expand true -fill both -side right

        pack $itk_component(buttonbar) -expand true -fill x -side bottom
        pack $itk_component(canvas) -expand true -fill both -side top

        eval itk_initialize $args

        loadScores
    }

    public method loadScores {} {
        set scoreObj [CubeScores \#auto]
        $scoreObj loadScores $filename
        
        set h [winfo height $itk_component(canvas)]
        set w [winfo width $itk_component(canvas)]
        
        set fontsize [getFontSize]
        set canv $itk_component(canvas)

        set headerHeight [expr {($h / 10)/2}]
        set width1 [expr {int(.5 * ($w / 3))}]
        set width2 [expr {int(1.5 * ($w / 3))}]
        set width3 [expr {int(2.5 * ($w / 3))}]
        if { [lsearch [font names] scoresHeader] < 0} {
            font create scoresHeader
            font configure scoresHeader -size $fontsize -weight bold \
                -family arial
        }
        $canv create text $width1 $headerHeight \
            -anchor center -font scoresHeader -text "Score"
        $canv create text $width2 $headerHeight \
            -anchor center -font scoresHeader -text "Level"
        $canv create text $width3 $headerHeight \
            -anchor center -font scoresHeader -text "When"
        
        set lineHeight [expr {($h - ($headerHeight *2))/10}]
        set count 0
        foreach elem [$scoreObj getScores] {
            foreach {score level when} $elem {break}
            set currHeight \
                [expr {($headerHeight *2) + ($lineHeight * ($count + 0.5))}]
            $canv create text $width1 $currHeight \
                -anchor center -font scoresHeader -text $score
            $canv create text $width2 $currHeight \
                -anchor center -font scoresHeader -text $level
            $canv create text $width3 $currHeight \
                -anchor center -font scoresHeader -text \
                [clock format $when -format "%m/%d/%Y"]
            incr count
        }

        return
    }

    protected method getFontSize {}
}

itcl::configbody CubeScoresWindow::filename {
    loadScores
}

itcl::body CubeScoresWindow::getFontSize {} {
    return 10

}
