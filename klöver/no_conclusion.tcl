 #Tcl/tk version 8.4.19.5 available here: www.activestate.com/activetcl/downloads 
#ActiveState ActiveTcl
#This is part of a tcl/tk user interface customized to the knowledge-based system shell Klöver.
#Developed by Petter Fogelqvist December-January 2011-2012 
 
 package require BWidget
 font create TopHeading -family calibri -size -25 -underline no -weight bold
 font create Btext -family calibri -size -13 -underline no
 font create Content -family calibri -size -12 -underline no
 font create SubHeading -family calibri -size -13 -underline no -weight bold
 
 set sw [ScrolledWindow .f1 -relief groove -borderwidth 4 -background #ffffff ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 500 -height 500 ]
    $sw setwidget $sf
    set subf [$sf getframe]


set a [frame $subf.a -relief groove -borderwidth 2]
label $a.object -text "Conclusions" -font TopHeading
pack $a.object -side top -pady 10
pack $a -padx 5 -pady 5 -ipadx 20 -ipady 10 -expand 1 -fill both


set b [frame $subf.b -relief groove -borderwidth 2]
label $b.label -text "No conclusions have been drawn." -font SubHeading
pack $b.label -anchor w -padx 5 -side top
button $b.ok -text "Ok" -background #50b4c8 -width 5 -command {prolog_event ok} -font Btext
pack $b.ok -side left -padx 5 -pady 5
pack $b -padx 5 -pady 5 -ipadx 20 -ipady 10 -expand 1 -fill both

pack $sw -ipadx 40 -ipady 10

bind $b.ok <Enter> { $b.ok config -background #a2d2db }
bind $b.ok <Leave> { $b.ok config -background #50b4c8 }

tk_setPalette #ffffff

font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading