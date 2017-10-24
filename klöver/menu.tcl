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
    set sf [ScrollableFrame $sw.f -width 450 -height 400 -background  #ffffff ]
    $sw setwidget $sf
    set subf [$sf getframe]
 
frame $subf.b -background #ffffff
label $subf.b.label -text "Quick OT App" -font TopHeading -background #ffffff
  
frame $subf.b.bf -relief groove -borderwidth 0 -background #ffffff
button $subf.b.bf.1 -text Start -background #50b4c8 -command {prolog_event "'Consult'"} -font Btext
button $subf.b.bf.2 -text "Consult given answers" -background #50b4c8 -command {prolog_event "'Consult with given answers'"} -font Btext
#button $subf.b.bf.3 -text "Save answers" -background #EED5B7 -command {prolog_event "'Save answers'"}
#button $subf.b.bf.4 -text "Save session" -background #EED5B7 -command {prolog_event "'Save session'"}
button $subf.b.bf.5 -text "Fetch old answers" -background #50b4c8 -command {prolog_event "'Fetch old answers'"} -font Btext
button $subf.b.bf.6 -text "Fetch old session" -background #50b4c8 -command {prolog_event "'Fetch old session'"} -font Btext
button $subf.b.bf.7 -text "List database" -background #50b4c8 -command {prolog_event "'List database'"} -font Btext
button $subf.b.bf.8 -text "Verify rules" -background #50b4c8 -command {prolog_event "'Verify rules'"} -font Btext
#button $subf.b.bf.9 -text "How explanation" -background #EED5B7 -command {prolog_event "'How explanation'"}
button $subf.b.bf.10 -text "Quit" -background #50b4c8 -command {prolog_event "'Interrupt'"} -font Btext
pack $subf.b.label -side top -pady 15 -padx 10
pack $subf.b.bf.1 $subf.b.bf.2 $subf.b.bf.5 $subf.b.bf.6 $subf.b.bf.7 $subf.b.bf.8 $subf.b.bf.10 -fill x -pady 10 -padx 200
#$subf.b.bf.3 $subf.b.bf.4 

pack $subf.b.bf -expand 1
pack $subf.b -ipadx 10 -ipady 10 -expand 1 -fill both

pack $sw -ipadx 40 -ipady 10 -padx 40

bind $subf.b.bf.1 <Enter> { $subf.b.bf.1 config -background #a2d2db }
bind $subf.b.bf.1 <Leave> { $subf.b.bf.1 config -background #50b4c8 }
bind $subf.b.bf.2 <Enter> { $subf.b.bf.2 config -background #a2d2db }
bind $subf.b.bf.2 <Leave> { $subf.b.bf.2 config -background #50b4c8 }
#bind $subf.b.bf.3 <Enter> { $subf.b.bf.3 config -background #CDB79E }
#bind $subf.b.bf.3 <Leave> { $subf.b.bf.3 config -background #EED5B7 }
#bind $subf.b.bf.4 <Enter> { $subf.b.bf.4 config -background #CDB79E }
#bind $subf.b.bf.4 <Leave> { $subf.b.bf.4 config -background #EED5B7 }
bind $subf.b.bf.5 <Enter> { $subf.b.bf.5 config -background #a2d2db }
bind $subf.b.bf.5 <Leave> { $subf.b.bf.5 config -background #50b4c8 }
bind $subf.b.bf.6 <Enter> { $subf.b.bf.6 config -background #a2d2db }
bind $subf.b.bf.6 <Leave> { $subf.b.bf.6 config -background #50b4c8 }
bind $subf.b.bf.7 <Enter> { $subf.b.bf.7 config -background #a2d2db }
bind $subf.b.bf.7 <Leave> { $subf.b.bf.7 config -background #50b4c8 }
bind $subf.b.bf.8 <Enter> { $subf.b.bf.8 config -background #a2d2db }
bind $subf.b.bf.8 <Leave> { $subf.b.bf.8 config -background #50b4c8 }
#bind $subf.b.bf.9 <Enter> { $subf.b.bf.9 config -background #CDB79E }
#bind $subf.b.bf.9 <Leave> { $subf.b.bf.9 config -background #EED5B7 }
bind $subf.b.bf.10 <Enter> { $subf.b.bf.10 config -background #a2d2db }
bind $subf.b.bf.10 <Leave> { $subf.b.bf.10 config -background #50b4c8 }

tk_setPalette #ffffff


#-background #ffffff

font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading