#Tcl/tk version 8.4.19.5 available here: www.activestate.com/activetcl/downloads 
#ActiveState ActiveTcl
#This is part of a tcl/tk user interface customized to the knowledge-based system shell Klöver.
#Developed by Petter Fogelqvist December-January 2011-2012 

 package require BWidget

 font create TopHeading -family calibri -size -25 -underline no -weight bold
 font create Btext -family calibri -size -13 -underline no
 font create Content -family calibri -size -12 -underline no
 font create SubHeading -family calibri -size -13 -underline no -weight bold
 
 set sw [ScrolledWindow .t -background #ffffff ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 400 -height 400 ]
    $sw setwidget $sf
    set subf [$sf getframe]
    
frame $subf.b -background #ffffff

frame $subf.b.title  -background #ffffff
label $subf.b.title.label -text "Verification menu" -font TopHeading
pack $subf.b.title.label -side top -ipady 10 -ipadx 10 
pack $subf.b.title -pady 10 -padx 10 
labelframe $subf.b.info -relief groove -borderwidth 1 -text "Information" -font SubHeading
label $subf.b.info.i -text "Result of the verification is printed to SICStus!" -font Content
pack $subf.b.info.i -ipady 5 -ipadx 5
pack $subf.b.info -fill x -pady 5 -padx 5
frame $subf.b.bf -relief groove -borderwidth 0
button $subf.b.bf.1 -text "Redundancy" -background #50b4c8 -command {prolog_event "'Redundancy'"} -font Btext
button $subf.b.bf.2 -text "Subsumption" -background #50b4c8 -command {prolog_event "'Subsumption'"} -font Btext
button $subf.b.bf.3 -text "Completeness" -background #50b4c8 -command {prolog_event "'Completeness'"} -font Btext
button $subf.b.bf.4 -text "Help" -background #50b4c8 -command {prolog_event "'Help'"} -font Btext
button $subf.b.bf.5 -text "Back" -background #50b4c8 -command {prolog_event "'Back'"} -font Btext

pack $subf.b.bf.1 $subf.b.bf.2 $subf.b.bf.3 $subf.b.bf.4  $subf.b.bf.5 -fill x -pady 3 -padx 30
pack $subf.b.bf -expand 1
pack $subf.b -ipadx 10 -ipady 10 -padx 105 -expand 1 -fill both


pack $sw -ipadx 40 -ipady 10 -padx 40

bind $subf.b.bf.1 <Enter> { $subf.b.bf.1 config -background #a2d2db }
bind $subf.b.bf.1 <Leave> { $subf.b.bf.1 config -background #50b4c8 }
bind $subf.b.bf.2 <Enter> { $subf.b.bf.2 config -background #a2d2db }
bind $subf.b.bf.2 <Leave> { $subf.b.bf.2 config -background #50b4c8 }
bind $subf.b.bf.3 <Enter> { $subf.b.bf.3 config -background #a2d2db }
bind $subf.b.bf.3 <Leave> { $subf.b.bf.3 config -background #50b4c8 }
bind $subf.b.bf.4 <Enter> { $subf.b.bf.4 config -background #a2d2db }
bind $subf.b.bf.4 <Leave> { $subf.b.bf.4 config -background #50b4c8 }
bind $subf.b.bf.5 <Enter> { $subf.b.bf.5 config -background #a2d2db }
bind $subf.b.bf.5 <Leave> { $subf.b.bf.5 config -background #50b4c8 }

tk_setPalette #ffffff
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading

#-background #ffff99