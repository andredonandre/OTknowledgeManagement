#Tcl/tk version 8.4.19.5 available here: www.activestate.com/activetcl/downloads 
#ActiveState ActiveTcl
#This is part of a tcl/tk user interface customized to the knowledge-based system shell Klöver.
#Developed by Petter Fogelqvist December-January 2011-2012 

 package require BWidget
 font create TopHeading -family calibri -size -25 -underline no -weight bold
 font create Btext -family calibri -size -13 -underline no
 font create Content -family calibri -size -12 -underline no
 font create SubHeading -family calibri -size -13 -underline no -weight bold
 font create ObjectO -family calibri -size -12 -slant italic
 set sw [ScrolledWindow .t -background #ffffff ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 400 -height 400 ]
    $sw setwidget $sf
    set subf [$sf getframe]
    
frame $subf.b -background  #ffffff 

frame $subf.b.title -background  #ffffff 
label $subf.b.title.label -text "Help menu" -font TopHeading
pack $subf.b.title.label -side top -ipady 10 -ipadx 10 
pack $subf.b.title -pady 10 -padx 10 
frame $subf.b.info -background  #ffffff 
message $subf.b.info.i -text "This is a beta version of an automated verification tool which analyze rule-bases in Klöver.
The purpose of this tool is to help the developer test his/her rules regarding consistency and completeness. 

The verification tool does not alter the rule-base in any way!" -font ObjectO -background #a2d2db  -justify center -width 430
pack $subf.b.info.i -ipady 2 -ipadx 2
label $subf.b.info.in -text "The options below give you more information of the specific implemented error checkers:" -font SubHeading
pack $subf.b.info.in -pady 5 -padx 10
pack $subf.b.info -fill x -padx 2
frame $subf.b.bf -relief groove -borderwidth 0 -background  #ffffff 

button $subf.b.bf.1 -text "Redundancy" -background #50b4c8 -command {prolog_event "'Redundancy'"} -font Btext
button $subf.b.bf.2 -text "Subsumption" -background #50b4c8 -command {prolog_event "'Subsumed'"} -font Btext
button $subf.b.bf.3 -text "Completeness" -background #50b4c8 -command {prolog_event "'Completeness'"} -font Btext
button $subf.b.bf.4 -text "Quit help" -background #50b4c8 -command {prolog_event "'Quit help'"} -font Btext

pack $subf.b.bf.1 $subf.b.bf.2 $subf.b.bf.3 $subf.b.bf.4 -side left -pady 3 -padx 8
pack $subf.b.bf -expand 1
pack $subf.b -ipadx 10 -ipady 10 -padx 10 -expand 1 -fill both


pack $sw -ipadx 40 -ipady 10 -padx 40

bind $subf.b.bf.1 <Enter> { $subf.b.bf.1 config -background #a2d2db }
bind $subf.b.bf.1 <Leave> { $subf.b.bf.1 config -background #50b4c8 }
bind $subf.b.bf.2 <Enter> { $subf.b.bf.2 config -background #a2d2db }
bind $subf.b.bf.2 <Leave> { $subf.b.bf.2 config -background #50b4c8 }
bind $subf.b.bf.3 <Enter> { $subf.b.bf.3 config -background #a2d2db }
bind $subf.b.bf.3 <Leave> { $subf.b.bf.3 config -background #50b4c8 }
bind $subf.b.bf.4 <Enter> { $subf.b.bf.4 config -background #a2d2db }
bind $subf.b.bf.4 <Leave> { $subf.b.bf.4 config -background #50b4c8 }

tk_setPalette #ffffff
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading
 font delete ObjectO
#-background #ffff99