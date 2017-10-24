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
  set sf [ScrollableFrame $sw.f -background  #ffffff -width 500 -height 650 ]
  $sw setwidget $sf
  set subf [$sf getframe]
	
global var
set Index 0
set Index2 0
set Num []
set Num2 []
set Object []
set Attribute []
set Value []
set String []
set Text []
set Nothing []

font create ObjectO -size -12 -weight bold

set a [frame $subf.a -relief groove -borderwidth 2 -background  #ffffff]
label $a.label -text "Conclusions" -font TopHeading
pack $a.label -side top -pady 10
pack $a -padx 5 -pady 10 -ipadx 5 -ipady 5 -fill x

set b [frame $subf.b]
prolog {num_answers(Num)}

while {$Index < $prolog_variables(Num)} {
	prolog {answer_options(Object)}
	
	if [prolog "text('$prolog_variables(Object)', String)"] {
		
		set ftable [frame $b.ftable$Index -relief groove -borderwidth 2 -background  #ffffff]
		message $ftable.ob -text "$prolog_variables(String)" -font SubHeading -justify center -width 400 
		pack $ftable.ob -padx 5 -pady 2 -ipadx 5 -ipady 2 -side top
		
		#init table
		tablelist::tablelist $ftable.table \
		-columns {0 "Category" 0 "Evaluation"} -height 3 -width 70 -stretch all -yscrollcommand [list $ftable.scroll set] -background #eee9e9 -font Content
		scrollbar $ftable.scroll -orient vertical -command [list $ftable.table yview] 
		prolog "num_attr_cf('$prolog_variables(Object)', Num2)"
		
		if {$prolog_variables(Num2) > 0} {
			
			while {$Index2 < $prolog_variables(Num2)} {
				prolog "attr_cf('$prolog_variables(Object)',Attribute, Value)"	

				if [prolog "evaluation($prolog_variables(Value),Text)"] { 
					$ftable.table insert end [list "$prolog_variables(Attribute)" "$prolog_variables(Text)"]
					if {$Index2>0 && $Index2%2} {
					$ftable.table rowconfigure $Index2 -background #eee9e9 -font Content -selectable 0
					} else {
					$ftable.table rowconfigure $Index2 -background #b0c4de -font Content -selectable 0
					}
					
				} else {
					$ftable.table insert end [list "$prolog_variables(Attribute)" "evaluation not defined (evaluation/2)"]
					if {$Index2>0 && $Index2%2} {
					$ftable.table rowconfigure $Index2 -background #eee9e9 -font Content -selectable 0
					} else {
					$ftable.table rowconfigure $Index2 -background #b0c4de -font Content -selectable 0
					}
					
				}
			
				prolog "retract_attr_list('$prolog_variables(Object)')"
				incr Index2
			} 
		} else { 
				$ftable.table insert end [list "No conclusions" ""]
				$ftable.table rowconfigure $Index2 -background #b0c4de -font Content -selectable 0
		}
		
	pack $ftable.table -side left -fill x -expand 1
	pack $ftable.scroll -side left -fill y
	pack $ftable -side top -pady 10 -padx 15 -fill x
	} else {
		frame $b.f$Index -relief groove -borderwidth 1
		label $b.f$Index.b -text "$prolog_variables(Object) -error: undefined object description (text/2)" -font Content
		pack $b.f$Index.b -padx 5 -pady 2 -ipadx 5 -ipady 2 -side top
		pack $b.f$Index -padx 15 -pady 10 -ipadx 5 -ipady 2 -fill x -side top -anchor nw
	}
	
	prolog {retract_answer(N,M)}
	incr Index
	set Index2 0
}
#ends while loop

pack $b	

frame $subf.buttons -background  #ffffff
button $subf.buttons.ok -text "Menu" -background #50b4c8 -width 5 -command {prolog_event ok} -font Btext

pack $subf.buttons.ok -padx 5 -pady 5 -side left
pack $subf.buttons

pack $sw -padx 40 -pady 20

bind $subf.buttons.ok <Enter> { $subf.buttons.ok config -background #a2d2db -font Btext } 	
bind $subf.buttons.ok <Leave> { $subf.buttons.ok config -background #50b4c8 -font Btext}

tk_setPalette #ffffff

font delete ObjectO
font delete TopHeading
font delete Btext
font delete Content
font delete SubHeading