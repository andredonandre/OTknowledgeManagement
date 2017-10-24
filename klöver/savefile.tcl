
 font create TopHeading -family calibri -size -25 -underline no -weight bold
 font create Btext -family calibri -size -13 -underline no
 font create Content -family calibri -size -12 -underline no
 font create SubHeading -family calibri -size -13 -underline no -weight bold

frame .t
#scrollbar .scrollbar -orient vertical

frame .t.f2
frame .t.f2.b -relief groove -borderwidth 2
frame .t.f2.b.ebox

label .t.f2.b.ebox.input -text "Give a filename:"
entry .t.f2.b.ebox.entry -textvariable evar -background #ffffff 
#set evar "Input answer here"
pack .t.f2.b.ebox.input -anchor w -padx 2 -side left
pack .t.f2.b.ebox.entry -anchor w -padx 2 -side right
pack .t.f2.b.ebox -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill both

frame .t.f2.b.box
#button .f2.b.box.ok -text "Ok" -background #EED5B7 -command {prolog_event "'$evar'"}
button .t.f2.b.box.ok -text "Ok" -background #50b4c8 -width 5 -command {ok $evar} -font Btext
pack .t.f2.b.box.ok -side left -padx 10 -pady 5
pack .t.f2.b.box -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill both

pack .t.f2.b -expand 1 -fill x
pack .t.f2 -side top -anchor nw -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 1 -fill both


proc ok {result} {

	if {$result == ""} {
		tk_messageBox -type ok -icon error -parent .t -message "Write a filename in the textbox!"
	} else {
		prolog_event "'$result'"
	}
}


pack .t -side left -anchor nw -padx 10 -pady 5 -ipadx 5 -ipady 5
#pack .scrollbar -side left -fill y

bind .t.f2.b.ebox.entry <Enter> { .t.f2.b.ebox.entry config -background #a2d2db }
bind .t.f2.b.ebox.entry <Leave> { .t.f2.b.ebox.entry config -background #50b4c8 }
bind .t.f2.b.box.ok <Enter> { .t.f2.b.box.ok config -background #a2d2db }
bind .t.f2.b.box.ok <Leave> { .t.f2.b.box.ok config -background #50b4c8 }

tk_setPalette #ffffff
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading
