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

 set sw [ScrolledWindow .t -background #ffffff ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 650 -height 650 ]
    $sw setwidget $sf
    set subf [$sf getframe]
	
set Index 0
set Num []
set Attribute []
set Value []
set A []
set B []
set C []
set A_error "No answers exists"
set T_error "No conclusions drawn"
set H_error "No how explanations exists"

font create ObjectO -family calibri -size -12 -weight bold

frame $subf.a -relief groove -borderwidth 2
label $subf.a.label -text "List database" -font TopHeading
pack $subf.a.label -side top -pady 2 -ipady 2
pack $subf.a -padx 2 -pady 2 -ipadx 5 -ipady 5 -fill x

# frame containing tables
set hold [frame $subf.hold]
set b [labelframe $hold.b -relief groove -borderwidth 2 -text "Given answers:" -font ObjectO]

tablelist::tablelist $b.table \
-columns {0 "Question" 0 "Answer"} -height 8 -width 90 -stretch all -yscrollcommand [list $b.scroll set] -background #eee9e9
scrollbar $b.scroll -orient vertical -command [list $b.table yview] 
prolog {num_answers(Num)}

#display answer/2
if [prolog "answer_options(('$A_error',Value))"] {
	$b.table insert end [list "$A_error" ""]
	$b.table rowconfigure 0 -background #b0c4de -selectable 0
	prolog {retract_answer(N,M)}
		
} else {
	while {$Index < $prolog_variables(Num)} {
		prolog {answer_options((Attribute,Value))}
		prolog "answer('$prolog_variables(Attribute)','$prolog_variables(Value)')"
		$b.table insert end [list "$prolog_variables(Attribute)" "$prolog_variables(Value)"]
		if {$Index>0 && $Index%2} {
			$b.table rowconfigure $Index -background #eee9e9 -selectable 0
		} else {
			$b.table rowconfigure $Index -background #b0c4de -selectable 0
		}
		prolog {retract_answer(N,M)}
		incr Index
	}
}
	
prolog {retract_number}
set Index 0
 
pack $b.table -side left -fill x -expand 1
pack $b.scroll -side left -fill y
pack $b -side top -pady 5 -padx 15 -fill x

#display trigged/3
set c [labelframe $hold.c -relief groove -borderwidth 2 -text "Conclusions:" -font ObjectO]
#init table
tablelist::tablelist $c.table \
-columns {0 "Object" 0 "Attribute" 0 "CF"} -height 8 -stretch all -yscrollcommand [list $c.scroll set] -background #eee9e9
scrollbar $c.scroll -orient vertical -command [list $c.table yview] 

prolog {num_answers(Num)}
if [prolog "answer_options(trigged('$T_error',B,C))"] {
		
	$c.table insert end [list "$T_error" "" ""]
	$c.table rowconfigure 0 -background #b0c4de -selectable 0
	prolog {retract_answer(N,M)}
		
} else {
	while {$Index < $prolog_variables(Num)} {
		prolog {answer_options(trigged(A,B,C))}
		prolog "trigged('$prolog_variables(A)','$prolog_variables(B)','$prolog_variables(C)')"
		$c.table insert end [list "$prolog_variables(A)" "$prolog_variables(B)" "$prolog_variables(C)"]
		if {$Index>0 && $Index%2} {
			$c.table rowconfigure $Index -background #eee9e9 -selectable 0
		} else {
			$c.table rowconfigure $Index -background #b0c4de -selectable 0
		}
	
	prolog {retract_answer(N,M)}
	incr Index
	}
}		

prolog {retract_number}
set Index 0
pack $c.table -side left -fill x -expand 1
pack $c.scroll -side left -fill y
pack $c -side top -pady 5 -padx 15 -fill x


#display how/4
set d [labelframe $hold.d -relief groove -borderwidth 2 -text "How explanations:" -font ObjectO -background #ffffff]
#init table
tablelist::tablelist $d.table \
-columns {0 "Rule" 0 "Object" 0 "Attribute" 0 "True/False"} -height 8 -stretch all -yscrollcommand [list $d.scroll set] -background #eee9e9
scrollbar $d.scroll -orient vertical -command [list $d.table yview] 

prolog {num_answers(Num)}
if [prolog "answer_options(how(B,'$H_error',C,D))"] {
		
	$d.table insert end [list "$H_error" "" ""]
	$d.table rowconfigure 0 -background #b0c4de -selectable 0
	prolog {retract_answer(N,M)}
		
} else {
	while {$Index < $prolog_variables(Num)} {
		prolog {answer_options(how(A,B,C,D))}
		prolog "how('$prolog_variables(A)','$prolog_variables(B)','$prolog_variables(C)','$prolog_variables(D)')"
		$d.table insert end [list "$prolog_variables(A)" "$prolog_variables(B)" "$prolog_variables(C)" "$prolog_variables(D)"]
		if {$Index>0 && $Index%2} {
			$d.table rowconfigure $Index -background #eee9e9 -selectable 0
		} else {
			$d.table rowconfigure $Index -background #b0c4de -selectable 0
		}
		prolog {retract_answer(N,M)}
		incr Index
	}
}		

prolog {retract_number}

pack $d.table -side left -fill x -expand 1
pack $d.scroll -side left -fill y
pack $d -side top -pady 5 -padx 15 -fill x
pack $hold

#buttons
frame $subf.buttons -background #ffffff
button $subf.buttons.ok -text "Back" -background #50b4c8 -width 5 -command {prolog_event ok} -font Btext
pack $subf.buttons.ok -padx 2 -pady 2
pack $subf.buttons -side top -pady 5 -ipady 5


pack $sw -padx 25 -pady 20

bind $subf.buttons.ok <Enter> { $subf.buttons.ok config -background #a2d2db }
bind $subf.buttons.ok <Leave> { $subf.buttons.ok config -background #50b4c8 }

tk_setPalette #ffffff
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading
font delete ObjectO
