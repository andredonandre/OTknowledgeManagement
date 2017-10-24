package require BWidget
 
set evar []

 set sw [ScrolledWindow .t -relief groove -borderwidth 0 -background #EED5B7 ]
    set sf [ScrollableFrame $sw.f -background  #ffe4c4 -width 300 -height 300 ]
    $sw setwidget $sf
    set subf [$sf getframe]

labelframe $subf.f2 -relief groove -borderwidth 2 -text "Load/Save file" -font ObjectO
frame $subf.f2.ebox

label $subf.f2.ebox.input -text "Name of the file:"
entry $subf.f2.ebox.entry -textvariable evar -background #EED5B7 
pack $subf.f2.ebox.input -anchor w -padx 2 -side left
pack $subf.f2.ebox.entry -anchor w -padx 2 -side right
pack $subf.f2.ebox -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill both

frame $subf.f2.box
button $subf.f2.box.ok -text "Ok" -background #EED5B7 -width 5 -command {ok $evar}	
pack $subf.f2.box.ok -side left -padx 10 -pady 5
pack $subf.f2.box -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill both

pack $subf.f2 -side top -anchor nw -padx 10 -pady 10 -ipadx 15 -ipady 15 -expand 1 -fill both


proc ok {result} {

	if {$result == ""} {
		tk_messageBox -type ok -icon error -parent .t -message "Write a filename in the textbox!"
	} else {
		prolog_event "'$result'"
	}
}


pack $sw -padx 40 -pady 20

bind $subf.f2.ebox.entry <Enter> { $subf.f2.ebox.entry config -background #CDB79E }
bind $subf.f2.ebox.entry <Leave> { $subf.f2.ebox.entry config -background #EED5B7 }
bind $subf.f2.box.ok <Enter> { $subf.f2.box.ok config -background #CDB79E }
bind $subf.f2.box.ok <Leave> { $subf.f2.box.ok config -background #EED5B7 }


tk_bisque
