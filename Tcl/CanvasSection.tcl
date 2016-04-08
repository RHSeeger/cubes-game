#
# $Header: /opt/cvs-repository/cubes/CanvasSection.tcl,v 1.7 2004/04/13 02:31:15 Robert Exp $
#

package require Tk
package require Itcl

itcl::class CanvasSection {
    public variable canvas
    public variable x1
    public variable y1
    public variable x2
    public variable y2

    public constructor {nCanvas nx1 ny1 nx2 ny2} {
        set canvas $nCanvas
        foreach elem {x1 x2 y1 y2} {
            set $elem [set n$elem]
        }
    }

    public method map {v1 v2}
    public method getHeight {} { expr {$y2 - $y1} }
    public method getWidth {} { expr {$x2 - $x1} }

    public proc drawScores {canv x1 y1 x2 y2 {filename ""}}
    public proc drawAbout {canv x1 y1 x2 y2}
    public proc makeFont {fontName}
    public proc makeButton {canv x1 y1 x2 y2 text tags args}
}

itcl::body CanvasSection::map {v1 v2} {
    switch -exact -- $v1 {
        x {
            return [expr {$x1 + $v2}]
        } y {
            return [expr {$y1 + $v2}]
        } default {
            return [list [expr {$x1 + $v1}] [expr {$y1 + $v2}]]
        }
    }
}

itcl::body CanvasSection::makeFont {fontName} {
    if { [lsearch [font names] $fontName] >= 0 } {
        return
    }
    font create $fontName
    switch -glob -- $fontName {
        scoresHeader {
            font configure $fontName -size 10 -weight bold -family arial
        }
        aboutHeader {
            font configure $fontName -size 20 -weight bold -family arial
        }
    }
}

itcl::body CanvasSection::drawAbout {canv x1 y1 x2 y2} {
    set buttonHeight 30

    set cObj [CanvasSection \#auto $canv $x1 $y1 \
                  $x2 [expr {$y2 -$buttonHeight}]]
    
    set h [$cObj getHeight]
    set w [$cObj getWidth]
    
    set headerHeight [$cObj map y [expr {$h / 10}]]
    set headerWidth [$cObj map y [expr {$w / 2}]]

    makeFont aboutHeader

    set cover [$canv create rectangle 0 0 \
                   [winfo width $canv] [winfo height $canv] \
                   -fill {} -outline {} -tags $cObj]
    $canv bind $cover <ButtonPress-3> {}
    $canv create rectangle $x1 $y1 $x2 $y2 -tags $cObj \
        -fill [$canv cget -background] -outline [$canv cget -background]

    $canv create text $headerWidth $headerHeight \
        -anchor center -font aboutHeader -text "Cubes" -tags $cObj

    set aboutText {
        {Created By: Robert Seeger}
        {Powered By: Tcl/Tk + Itcl}
        {With thanks to everyone}
        {from the Tcler's Wiki}
    }

    set lineHeight [expr {($h - ($headerHeight*2))/[llength $aboutText]}]
    set count 0
    foreach elem $aboutText {
        set elem [string trim $elem]
        set fColor black
        set currHeight \
            [expr {($headerHeight) + ($lineHeight * ($count + 0.5))}]
        $canv create text $headerWidth [$cObj map y $currHeight] \
            -anchor center -font scoresHeader -text $elem -tags $cObj \
            -fill $fColor
        incr count
    }

    set sh [winfo screenheight $canv]
    set sw [winfo screenwidth $canv]
    set smmh [winfo screenmmheight $canv]
    set smmw [winfo screenmmwidth $canv]
    
    set h [expr {8 * ($sh / $smmh)}]
    set w [expr {16 * ($sw / $smmw)}]

    makeButton $canv \
        [expr { (($x2 + $x1)/2) - ($w / 2) }] \
        [expr { ($y2 - 0.5*$buttonHeight) - ($h / 2) }] \
        [expr { (($x2 + $x1)/2) + ($w / 2) }] \
        [expr { ($y2 - 0.5*$buttonHeight) + ($h / 2) }] \
        "Ok" [list $cObj "OK$cObj"] \
        -command [list $canv delete withtag $cObj]
}

itcl::body CanvasSection::drawScores {canv x1 y1 x2 y2 {filename ""}} {
    set buttonHeight 30

    set scoreObj [CubeScores \#auto]
    $scoreObj loadScores $filename

    set cObj [CanvasSection \#auto $canv $x1 $y1 \
                  $x2 [expr {$y2 -$buttonHeight}]]
    
    set h [$cObj getHeight]
    set w [$cObj getWidth]
    
    set headerHeight [expr {($h / 10)/2}]
    set width1 [expr {int(.5 * ($w / 3))}]
    set width2 [expr {int(1.5 * ($w / 3))}]
    set width3 [expr {int(2.5 * ($w / 3))}]

    makeFont scoresHeader

    set cover [$canv create rectangle 0 0 \
                   [winfo width $canv] [winfo height $canv] \
                   -fill {} -outline {} -tags $cObj]
    $canv bind $cover <ButtonPress-3> {}
    $canv create rectangle $x1 $y1 $x2 $y2 -tags $cObj \
        -fill [$canv cget -background] -outline [$canv cget -background]

    $canv create text [$cObj map x $width1] [$cObj map y $headerHeight] \
        -anchor center -font scoresHeader -text "Score" -tags $cObj
    $canv create text [$cObj map x $width2] [$cObj map y $headerHeight] \
        -anchor center -font scoresHeader -text "Level" -tags $cObj
    $canv create text [$cObj map x $width3] [$cObj map y $headerHeight] \
        -anchor center -font scoresHeader -text "When" -tags $cObj
    
    set lineHeight [expr {($h - ($headerHeight *2))/10}]
    set count 0
    foreach elem [$scoreObj getScores] {
        foreach {score level when} $elem {break}
        set fColor [lindex {blue purple red yellow} [expr {$count % 4}]]
        set currHeight \
            [expr {($headerHeight *2) + ($lineHeight * ($count + 0.5))}]
        $canv create text [$cObj map x $width1] [$cObj map y $currHeight] \
            -anchor center -font scoresHeader -text $score -tags $cObj \
            -fill $fColor
        $canv create text [$cObj map x $width2] [$cObj map y $currHeight] \
            -anchor center -font scoresHeader -text $level -tags $cObj \
            -fill $fColor
        $canv create text [$cObj map x $width3] [$cObj map y $currHeight] \
            -anchor center -font scoresHeader -text \
            [clock format $when -format "%m/%d/%Y"] -tags $cObj \
            -fill $fColor
        incr count
    }

        

    set sh [winfo screenheight $canv]
    set sw [winfo screenwidth $canv]
    set smmh [winfo screenmmheight $canv]
    set smmw [winfo screenmmwidth $canv]
    
    set h [expr {8 * ($sh / $smmh)}]
    set w [expr {16 * ($sw / $smmw)}]

    makeButton $canv \
        [expr { (($x2 + $x1)/2) - ($w / 2) }] \
        [expr { ($y2 - 0.5*$buttonHeight) - ($h / 2) }] \
        [expr { (($x2 + $x1)/2) + ($w / 2) }] \
        [expr { ($y2 - 0.5*$buttonHeight) + ($h / 2) }] \
        "Ok" [list $cObj "OK$cObj"] \
        -command [list $canv delete withtag $cObj]
}

itcl::body CanvasSection::makeButton {canv x1 y1 x2 y2 text tags args} {
    set rect [drawing::rect $canv $x1 $y1 $x2 $y2 3 green $text]
    foreach tag $tags {
        foreach elem $rect {
            $canv addtag $tag withtag $elem
        }
    }
    foreach {key value} $args {
        switch -exact -- $key {
            -command {
                foreach elem $rect {
                    $canv bind $elem <ButtonPress-1> $value
                }
            }
        }
    }
}
