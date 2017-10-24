 #Tcl/tk version 8.4.19.5 available here: www.activestate.com/activetcl/downloads 
#ActiveState ActiveTcl
#This is part of a tcl/tk user interface customized to the knowledge-based system shell Klöver.
#Developed by Petter Fogelqvist December-January 2011-2012 
 
 package require BWidget
 package require Tablelist

 font create TopHeading -family calibri -size -25 -underline no -weight bold
 font create Btext -family calibri -size -13 -underline no
 font create Content -family calibri -size -12 -underline no
 font create SubHeading -family calibri -size -13 -underline no -weight bold
 
 #scrollable window setup
 set sw [ScrolledWindow .t -relief groove -borderwidth 0 -background #ffffff ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 360 -height 450 ]
    $sw setwidget $sf
    set subf [$sf getframe]

set Index 0
set Num []
set Attribute []
set Value []

frame $subf.f1 -relief groove -borderwidth 2 -background #ffffff
label $subf.f1.label -text "Loaded answers" -font TopHeading
pack $subf.f1.label -side top -pady 5
pack $subf.f1 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill x

prolog {num_answers(Num)}

set ftable [frame $subf.ftable]
tablelist::tablelist $ftable.table \
-columns {0 "Question" 0 "Answer"} -height 20 -width 50 -stretch all \
-yscrollcommand [list $ftable.scroll set] -background #eee9e9
 
scrollbar $ftable.scroll -orient vertical -command [list $ftable.table yview] 
while {$Index < $prolog_variables(Num)} {
	prolog {answer_options((Attribute,Value))}
	$ftable.table insert end [list "$prolog_variables(Attribute)" "$prolog_variables(Value)"]
	if {$Index>0 && $Index%2} {
	$ftable.table rowconfigure $Index -background #eee9e9 -selectable 0
	} else {
	$ftable.table rowconfigure $Index -background #b0c4de -selectable 0
	}
	prolog {retract_answer(N,M)}
	incr Index
	}

pack $ftable.table -side left -fill x -expand 1
pack $ftable.scroll -side left -fill y
pack $ftable -side top -padx 5 -pady 5 -ipadx 5 -ipady 0 -expand 1 -fill x

set f2 [frame $subf.f2]
frame $f2.g1
button $f2.g1.ok -text "Menu" -background #50b4c8 -width 5 -command {prolog_event ok} -font Btext
pack $f2.g1.ok -anchor s -padx 5 -pady 0
pack $f2.g1 -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 0 -expand 1 -fill both

pack $f2 -side top -padx 5 -pady 5 -ipadx 10 -ipady 10 -expand 1 -fill both

pack $sw -padx 40 -pady 20

bind $f2.g1.ok <Enter> { $f2.g1.ok config -background #a2d2db }
bind $f2.g1.ok <Leave> { $f2.g1.ok config -background #50b4c8 }

tk_setPalette #ffffff
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading
###font create TkFixedFont -family Courier -size -12
