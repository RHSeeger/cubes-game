#
# $Header: /opt/cvs-repository/cubes/CubeWindow.tcl,v 1.28 2004/04/13 02:53:19 Robert Exp $
#

package require Itk
package require Iwidgets
itcl::class CubeWindow {
    inherit itk::Widget

    public variable dataobject {}

    protected variable score 0
    protected variable life 10
    protected variable level 1
    protected variable coverFont
    protected variable isHidden 0

    protected variable blockHeight 1
    protected variable blockWidth 1
    
    protected common BONUS_SCORE 250

    constructor {args} {
        itk_component add menubar {
            iwidgets::menubar $itk_interior.menubar -menubuttons {
                menubutton file -text "File" -menu {
                    command new -label "New Game" \
                        -command {[itcl::code $this newGame]}
                    command exit -label "Exit" \
                        -command {[itcl::code $this exitGame]}
                }
                menubutton scores -text "Scores" -menu {
                    command showscores -label "Show High Scores" \
                        -command {[itcl::code $this showWindow drawScores]}
                    command clearscores -label "Clear High Scores" \
                        -command {puts "Clear High Scores"}
                }
                menubutton help -text "Help" -menu {
                    command howtoplay -label "How to play"\
                        -command {puts "How to play"}
                    command about -label "About..."\
                        -command {[itcl::code $this showWindow drawAbout]}
                }
            }
        }

        itk_component add canvas {
            canvas $itk_interior.display \
                -background white -relief sunken -borderwidth 1 
        } {
            usual
        }

        itk_component add statusFrame {
            frame $itk_interior.statusFrame -relief sunken  -borderwidth 1
        } {
            usual
        } 

        itk_component add scoreFrame {
            frame $itk_interior.statusFrame.scoreFrame
        } {
            usual
        } 

        itk_component add lifeFrame {
            frame $itk_interior.statusFrame.lifeFrame
        } {
            usual
        } 

        itk_component add scoreText {
            label $itk_interior.statusFrame.scoreFrame.text \
                -text "Score: "
        } {
            usual
            rename -background -labelbackground labelBackground Background
        }

        itk_component add scoreValue {
            label $itk_interior.statusFrame.scoreFrame.value \
                -textvariable [itcl::scope score]
        } {
            usual
            rename -background -labelbackground labelBackground Background
        }

        itk_component add lifeText {
            label $itk_interior.statusFrame.lifeFrame.text -text "Life: "
        } {
            usual
            rename -background -labelbackground labelBackground Background
        }

        itk_component add lifeValue {
            label $itk_interior.statusFrame.lifeFrame.value \
                -textvariable [itcl::scope life]
        } {
            usual
            rename -background -labelbackground labelBackground Background
        }

        pack $itk_component(menubar) -side top -expand no -fill x

        pack $itk_component(scoreText) -side left -expand no -fill none
        pack $itk_component(scoreValue) -side left -expand no -fill none
        pack $itk_component(lifeText) -side left -expand no -fill none
        pack $itk_component(lifeValue) -side left -expand no -fill none

        pack $itk_component(lifeFrame) -side right -expand yes -fill x
        pack $itk_component(scoreFrame) -side right -expand yes -fill x

        pack $itk_component(canvas) -side top -expand yes -fill both
        pack $itk_component(statusFrame) -side bottom -expand yes -fill x

        eval itk_initialize $args

        set sh [winfo screenheight $itk_component(canvas)]
        set sw [winfo screenwidth $itk_component(canvas)]
        set smmh [winfo screenmmheight $itk_component(canvas)]
        set smmw [winfo screenmmwidth $itk_component(canvas)]

        set h [expr {8 * ($sh / $smmh)}]
        set w [expr {8 * ($sw / $smmw)}]

        $itk_component(canvas) configure \
            -width [expr {int([$dataobject width] * $w +6)}] \
            -height [expr {int([$dataobject height] * $h +6)}]

        bind $itk_component(canvas) <ButtonRelease-3> \
            [itcl::code $this redrawIfHidden]

        set coverFont [font create]
        font configure $coverFont -size 25 -weight bold -family arial

    }

    public method append {info}
    public method redraw {}
    
    protected method drawCube {h w height width type} {}
    protected method * {v1 v2} { expr { $v1 * $v2 } }

    protected method showMove {y x}
    protected method redrawIfHidden {}
    public method clicked {y x} {
        set newscore [$dataobject clicked $y $x]
        set old [expr {$score / $BONUS_SCORE}]
        incr score $newscore
        incr life [expr {($score / $BONUS_SCORE) - $old}]

        #puts "$newscore -> $score"
        while {[$dataobject siftDown] || [$dataobject siftLeft]} {}
        redraw
        update idletasks
        if { ![$dataobject hasMoves] } {
            set life [expr {$life - [$dataobject numCubes]}]
            set life [expr {$life < 0 ? 0 : $life}]
            if { $life > 0 } {
                makeCover "Level [incr level]"
                after 3000 [itcl::code $this nextScreen]
            } else {
                makeCover "Game Over" "Your Score: $score"
                CubeScores::loadAddSaveScore $score $level [clock seconds]
                after 3000 [itcl::code $this showWindow drawScores]
            }
        }
    }

    protected method nextScreen {} {
        $itk_component(canvas) delete -withtag cover
        set data [$dataobject getData]
        set height [llength $data]
        set width [llength [lindex $data 0]]
        $dataobject populate $height $width
        redraw
    }

    protected method makeCover {args} 
    public method showWindow {action}
    public method doneScores {}
    #public method showAbout {}

    protected method newGame {}
    protected method exitGame {}

    protected method confirmBox {message}
}

itk::usual CubeWindow {
    keep -background -cursor -foreground -font
    keep -activebackground -activerelief
    keep -highlightcolor -highlightthickness
    keep -insertbackground -insertborderwidth -insertwidth
    keep -insertontime -insertofftime
    keep -selectbackground -selectborderwidth -selectforeground
    keep -textbackground -troughcolor
}

itcl::configbody CubeWindow::dataobject {
    after 1 [list $this redraw]
}

itcl::body CubeWindow::append {info} {
    $itk_component(text) configure -state normal
    $itk_component(text) insert end $info
    $itk_component(text) configure -state disabled
}

itcl::body CubeWindow::redraw {} {
    set canv $itk_component(canvas)

    if { ![string length $dataobject] } {
        return
    }
    if {![winfo viewable $itk_component(canvas)]} {
        after 10 [list $this redraw]
        return
    }

    $itk_component(canvas) delete all

    set data [$dataobject getData]
    set dw [llength [lindex $data 0]]
    set dh [llength $data]

    set border [$itk_component(canvas) cget -borderwidth]
    set ww [expr {[winfo width $itk_component(canvas)] - $border}]
    set wh [expr {[winfo height $itk_component(canvas)] - $border}]

    set blockWidth [set cw [expr {double($ww) / $dw}]]
    set blockHeight [set ch [expr {double($wh) / $dh}]]

    for {set currh 0} {$currh < $dh} {incr currh} {
        for {set currw 0} {$currw < $dw} {incr currw} {
            set type [lindex $data $currh $currw]
            if {[string length $type]} {
                drawCube $currh $currw $ch $cw $type
            }
        }
    }
    #makeCover "Omg" "I can't believe it"

}

itcl::body CubeWindow::drawCube {h w height width type} {
    set canv $itk_component(canvas)

    set text ""
    if {[CubeData::isLike "color:*" $type]} {
        scan $type "color:%s" color
    } elseif {[CubeData::isLike "mult:*" $type]} {
        set color grey
        scan $type "mult:%s" mult
        set text "x$mult"
    } elseif {[CubeData::isLike "span:*" $type]} {
        set color darkgrey
        scan $type "span:%s" add
        set text "+$add"
    } else {
        set color black
    }

    set x1 [expr {int($w * $width)}]
    set y1 [expr {int($h * $height)}]
    set x2 [expr {int(($w +1) * $width)}]
    set y2 [expr {int(($h +1) * $height)}]

    set items [drawing::rect $itk_component(canvas) $x1 $y1 $x2 $y2 \
                   3 $color $text]
    foreach elem $items {
        $canv bind $elem <ButtonPress-1> [itcl::code $this clicked $h $w]
        $canv bind $elem <ButtonPress-3> [itcl::code $this showMove $h $w]
        $canv bind $elem <ButtonRelease-3> [itcl::code $this redraw]
        $canv addtag "y${h}x${w}" withtag $elem
    }
    set bbox [eval $canv bbox $items]
}


itcl::body CubeWindow::showMove {y x} {
    set items [$itk_component(canvas) find withtag "y${y}x${x}"]
    #puts $items
    foreach item [$dataobject ifClicked $y $x] {
        #puts $item
        foreach {ny nx} $item {
            $itk_component(canvas) delete withtag "y${ny}x${nx}"
        }
    }
    set isHidden 1
}

itcl::body CubeWindow::redrawIfHidden {} {
    if { $isHidden } {
        set isHidden 0
        redraw
    }
}

itcl::body CubeWindow::makeCover {args} {
    set width [winfo width $itk_component(canvas)]
    set height [winfo height $itk_component(canvas)]
    #puts "$args : $width $height"

    $itk_component(canvas) create rectangle 0 0 $width $height \
        -fill {} -outline {} -tag cover
    set cover [$itk_component(canvas) find withtag cover]

    set len [llength $args]
    for {set i 0} {$i < $len} {incr i} {
        set h [expr {int(($i +1) * $height / ($len+1))}]
        $itk_component(canvas) create text [expr {$width / 2}] $h \
            -anchor center -text [lindex $args $i] \
            -tag cover -fill black -font $coverFont
    }
}

itcl::body CubeWindow::showWindow {action} {
    set w [winfo width $itk_component(canvas)]
    set h [winfo height $itk_component(canvas)]
    set bd [$itk_component(canvas) cget -borderwidth]
    CanvasSection::$action $itk_component(canvas) \
        [expr {int($blockWidth)}] [expr {int($blockHeight)}] \
        [expr {int($w - $blockWidth - (2 * $bd))}] \
        [expr {int($h - $blockHeight - (2 * $bd))}]
}

itcl::body CubeWindow::doneScores {} {
    catch { destroy $itk_component(canvas).scores }
    redraw
    if {$life <= 0} {
        makeCover "Game Over" "Your Score: $score"
    }
}

itcl::body CubeWindow::newGame {} {
    if { $life > 0 } {
        makeCover
        if {![confirmBox "Are you sure you want to abandon this game"]} {
            redraw
            return
        }
    }
    set score 0
    set life 10
    nextScreen
}

itcl::body CubeWindow::exitGame {} {
    if { $life > 0 } {
        makeCover
        if {![confirmBox "Are you sure you want to abandon this game"]} {
            redraw
            return
        }
    }
    exit
}

itcl::body CubeWindow::confirmBox {message} {
    return 1
}
