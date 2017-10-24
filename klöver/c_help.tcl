 #Tcl/tk version 8.4.19.5 available here: www.activestate.com/activetcl/downloads 
#ActiveState ActiveTcl
#This is part of a tcl/tk user interface customized to the knowledge-based system shell Klöver.
#Developed by Petter Fogelqvist December-January 2011-2012 
 
 package require BWidget

 font create Title -family calibri -size -25 -underline no -weight bold
 font create ObjectO -size -12 -slant italic 
 font create Button -family calibri -size -13 -underline no 
 font create Text -family calibri -size -12 -underline no 
 set sw [ScrolledWindow .t -background #FFFFFF ]
    set sf [ScrollableFrame $sw.f -background  #ffffff -width 410 -height 500 ]
    $sw setwidget $sf
    set subf [$sf getframe]

frame $sw.t -background  #ffffff     
frame $subf.b -background  #ffffff 

frame $subf.b.title -background  #ffffff 
label $subf.b.title.label -text "Completeness" -font Title -background  #ffffff 
pack $subf.b.title.label -side top -ipady 10 -ipadx 10 
pack $subf.b.title -pady 10 -padx 10 
frame $subf.b.info -background  #ffffff 
message $subf.b.info.i -text "The 'Completeness' option detects:
1. Unreachable rules.
2. Missing rules.

The tool checks:
(1)if there exist rules with identical rule numbers and objects in the rule base.
(1)if all rule numbers exists in rule_info/2.
(1)if each object in the rule-base are represented in a clause of rule_info/2.
(1)if each object in the rule-base are represented in the list of goal_conclusions/1.
(2)if rule numbers present in rule_info/2 have a correspondent rule in the rule base." \
 -background #dbdbdb  -justify left -width 430 -font Text
pack $subf.b.info.i -ipady 2 -ipadx 2
pack $subf.b.info -fill x -padx 2

frame $subf.b.bf -relief groove -borderwidth 0 -background  #ffffff 

button $subf.b.bf.1 -text "See examples" -background #50b4c8 -command {example $subf} -font Button
button $subf.b.bf.2 -text "Back" -width 10 -background #50b4c8 -command {back $subf} -font Button

pack $subf.b.bf.1 $subf.b.bf.2  -side left -pady 3 -padx 20
pack $subf.b.bf -expand 1 -fill x
pack $subf.b -ipadx 10 -ipady 10 -padx 20 -expand 1 -fill both

proc back {subf} {
		destroy $subf.c
		prolog_event "'Back'"
}

proc example {subf} {
labelframe $subf.c -relief groove -borderwidth 2 -text "Examples of incompleteness" -font Text -background #FFFFFF

	message $subf.c.p -text "Format: rule(Rule_Number, Rule_Class, Rule_Attribute, Certainty_factor)
	
Example of two rules with duplicated rule numbers and conclusions in Klöver:
rule(1, Class1, Attribute1, 400) :-
premise(A),
premise(B).
	
has the same rule number and class as:
	
rule(2, Class1, Attribute2, 600) :-
premise(C). 
	
The second rule will never be reached when the first rule succeeds.
	
------------------------------------------------------------------

Example of an unreachable rule in Klöver:
rule_info(Class1, (1,3,4,5,6,7,8,9)).
	
rule(2,Class1, Attribute1,600):-
premise(A).
	
The rule-number 2 is not represented in the clause of rule_info/2.
	
-------------------------------------------------------------------
	
Example of a missing clause of rule_info/2 in Klöver:
rule_info(Class2,(3)).
	
rule(1,Class1, Attribute1,600):-
premise(A).
	
rule(3,Class2, Attribute1,200):-
premise(B).
	
A clause of rule_info/2 for Class1 is missing.
	
-------------------------------------------------------------------
	
Example of a missing class in goal_conclusions/1 in Klöver:
goal_conclusions((Class1))
	
rule(1,Class1, Attribute1,600):-
premise(A).
	
rule(3,Class2, Attribute1,200):-
premise(B).
	
Class2 is missing in goal_conclusions/1.
	
--------------------------------------------------------------------
	
Example of a missing rule in Klöver:
(when a number in rule_info\2 does not have a correspondent rule in the rule base)
	
rule_info(Class2,(10,20,30,)).
	
rule(10,Class2, Attribute1,600):-
premise(A).
	
rule(30,Class2, Attribute2,-500):-
premise(B).
	
There is no rule in the rule base with rule-number 20." -background #ffffff  -justify left -width 420 -font Text
pack $subf.c.p -fill x

	$subf.b.bf.1 configure -state disabled
	pack $subf.c -ipadx 10 -ipady 10 -expand 1 -fill both
}

pack $sw -ipadx 40 -ipady 10 -padx 40 

bind $subf.b.bf.1 <Enter> { $subf.b.bf.1 config -background #a2d2db }
bind $subf.b.bf.1 <Leave> { $subf.b.bf.1 config -background #50b4c8 }
bind $subf.b.bf.2 <Enter> { $subf.b.bf.2 config -background #a2d2db }
bind $subf.b.bf.2 <Leave> { $subf.b.bf.2 config -background #50b4c8 }

tk_setPalette #ffffff

 font delete ObjectO
#-background #ffff99