:- set_prolog_flag(discontiguous_warnings,off).
:- set_prolog_flag(single_var_warnings,off).
:- use_module(library(tcltk)).

%dynamic predicates for tcl GUI and verification of rule base: 
:- dynamic tcl/1, tcl_question/5, answer_options/1, num_answers/1, attr_cf/3, num_attr_cf/2, subsumed_rules/4, missing_rules/2, non_reached_rule/2, not_unique/1, redundant_rule/2, no_goal/1, missing_goal/1.

                                % Window 1 - INTERPRETER

% *******************************************
% ************* Top level **********************

%activate/deactivate tcl graphic user interface, change value "on" to something else to turn off tcl GUI 
tcl_GUI(on).   
%tcl_GUI(off).

%Clean window and displays Options menu (tcl).
expert:- 
		tcl_GUI(on),
		retractall(tcl(_)),
		delete_all_tcl,
		tk_new([top_level_events,name('Kl�ver')],Tcl),
		assert(tcl(Tcl)),
		Source = 'source k:/kl�ver/menu.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event),
		start_manipulate(Event),
        control_new_option(Event).
%Clean window and displays Options menu (SICStus).		
expert:-
		\+tcl_GUI(on),
		nl,
        write('Options:'),nl,nl,
        menue_write(['Consult' ,'Consult with given answers',
            'Save answers', 'Save session', 'Fetch old answers',
            'Fetch old session','List database', 'Verify rules', 'Quit']),
        read(Answer),
        start_manipulate(Answer),
        control_new_option(Answer).

start_manipulate(Answer):-
        run_option(Answer).

control_new_option(Answer):-
        Answer \== 'Quit',
        Answer \== 'Interrupt',
        new_menue(New_Answer),        
        start_manipulate(New_Answer),
        control_new_option(New_Answer).

control_new_option(New_Answer).

% Menu represented with the results presentation (Tcl).
new_menue(Event):-
		tcl_GUI(on),
		delete_all_tcl,
		Source = 'source k:/kl�ver/new_menu.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event).
% Menu represented with the results presentation (SICStus).
new_menue(Answer):-
          \+tcl_GUI(on),
		  nl,
          menue_write(['New session' ,'Consult with given answers',
             'Change answers','Save answers', 'Save session',
             'Fetch old answers','Fetch old session','List database', 'Verify rules', 
             'How explanation', 'Interrupt', 'Select an option, please! ']),
        read(Answer).		

menue_write([]):- nl.
menue_write([First|List]):-
        write(First),nl,
        menue_write(List).


% Gives consultation without old answers.
run_option('Consult'):-
                        retractall(answer(_,_)),
                        consultation.
% Consultation with already given answers.

run_option('Consult with given answers'):-
                        consultation.

run_option('New session'):-
        run_option('Consult').

run_option('Change answers'):-
		\+tcl_GUI(on),
        setof((Attribute,=,Value), Value^answer(Attribute,  Value), List_of_answers),
        menue_write(List_of_answers),        
        read_input(List_of_answers, To_change),
        delete_answers(To_change),
        ask_user(To_change).
run_option('Change answers'):-
		tcl_GUI(on),
        bagof((Attribute,Value), Value^answer(Attribute,  Value), List_of_answers),
        assert_each_option(List_of_answers),
        assert_num_options(List_of_answers),
		Source = 'source k:/kl�ver/change_answers.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event),
		tcl_list_to_prolog_list(Event,ASCII_Ans),
		get_answer_list(List_of_answers, ASCII_Ans, To_change), 
		convert_to_objects(To_change, New),
		delete_answers(New),
        ask_user(New).
run_option('Change answers'):-
		tcl_GUI(on).	
		
run_option('Change answers'):-
        \+tcl_GUI(on),
		write_no_answers.

% Saves answers and complete session on file.
run_option('Save answers'):-
        store_answers,!.
%if user choose to not save new file (i.e. store_answers fails)		
run_option('Save answers'):-
        tcl_GUI(on).
run_option('Save session'):-
        store_session,!.
%if store_session fails	
run_option('Save session'):-
        tcl_GUI(on).        
% Runs old answers and a session from file and makes a list of both. 
run_option('Fetch old answers') :-
        \+tcl_GUI(on),
		retractall(answer(_,_)),
        retractall(trigged(_,_,_)),
        retractall(how(_,_,_,_)),
        read_answerfile,
        write('Given answers'),nl,
        listing(answer).
run_option('Fetch old answers') :-
        tcl_GUI(on),
        read_answerfile,!,
		setof((Attribute,Value), Value^answer(Attribute,  Value), List_of_answers),
        assert_each_option(List_of_answers),
        assert_num_options(List_of_answers),
		Source = 'source k:/kl�ver/show_old.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event).
%if user choose to not open new file (i.e. read_answers fails)			
run_option('Fetch old answers') :-
		tcl_GUI(on).	
run_option('Fetch old session') :-
		\+tcl_GUI(on),
        retractall(answer(_,_)),
        retractall(trigged(_,_,_)),
        retractall(how(_,_,_,_)),
        read_answerfile,
        run_option('List database').		
run_option('Fetch old session') :-
		tcl_GUI(on),
        read_answerfile,!,
        run_option('List database').
run_option('Fetch old session') :-
		tcl_GUI(on).		
% Lists database content.
run_option('List database') :- 
        \+tcl_GUI(on),
		delete_garbage,
        nl,
        write('Given answers'), nl,
        (listing(answer); write('Exists no')), nl,
        write('Conclusions'), nl, 
        (listing(trigged); write('Exists no')), nl,
        write('The result of all rules'), nl,
        (listing(how); write('Exists no')).
%Assert database and display it in tcl file
run_option('List database') :- 
        tcl_GUI(on),
		delete_garbage,
		(
		setof((Attribute,Value), Value^answer(Attribute, Value), List_of_answers),
		assert_each_option(List_of_answers),
        assert_num_options(List_of_answers);
		assert(answer_options(('No answers exists',_)))),
		(
        setof(trigged(Object,Attribute,Value), trigged(Object,Attribute,Value), List_of_trigged),
		assert_each_option(List_of_trigged),
        assert_num_options(List_of_trigged);
		assert(answer_options(trigged('No conclusions drawn',_,_)))),
		(
		setof(how(FR,Object,Attribute,TF), how(FR,Object,Attribute,TF), List_of_how),
		assert_each_option(List_of_how),
        assert_num_options(List_of_how);
		assert(answer_options(how(_,'No how explanations exists',_,_)))),
		Source = 'source k:/kl�ver/show_result.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event).
	
 % Verification of rule-base:
 run_option('Verify rules'):-
		\+tcl_GUI(on),
		nl,
		write('*************************'),nl,
		write('VERIFICATION TOOL MENU'),nl,nl,
		write('Check:'), nl,nl,
		menue_write(['Redundancy','Subsumed',
             'Completeness', 'Help','Back']),
        read(Input),
		go_verify(Input).		
run_option('Verify rules'):-
		tcl_GUI(on),
		Source = 'source k:/kl�ver/verify.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event),
		go_verify(Event).
		
run_option('How explanation'):-
        answer_howquestion.

run_option('Interrupt'):-
        \+tcl_GUI(on),
		abort.
		
run_option('Interrupt'):-
        tcl_GUI(on),
		tcl(Tcl),
		tcl_delete(Tcl),
		abort.
		
%Case: Tcl GUI closed down by user - then Kl�ver stops.		
run_option([]):-  
		tcl_GUI(on),
		abort.

% Terminates Options.
run_option('Quit'):-
		\+tcl_GUI(on),
        abort.
		
run_option('Quit'):-
		tcl_GUI(on),
		tcl(Tcl),
		tcl_delete(Tcl),
        abort.

run_option(Answer):-
        write('That option does not exist, please try another one! '), nl.


read_input(List_of_answers, Answer):-
        write('Which answers do you want to change? Select the object, please! '),
        write('Please insert an object and finish the insertion with the word stop. '), nl,
        read_all_answers(_,Answer, start).

write_no_answers:-
        write('There are no answers!'),!, nl.

delete_answers([]).
delete_answers([stop]):- \+tcl_GUI(on).
delete_answers([Answer| Rest]):-
        retractall(answer(Answer,_)),
        delete_answers(Rest).

delete_garbage:-
        retractall(answer),
        retractall(trigged),
        retractall(how).

% ***************************************************
% ********** Predicates called by 'Options' *********

% Makes a consultation with or without questions.
consultation:-
        retractall(trigged(_,_,_)),
        retractall(how(_,_,_,_)),
        create_knowledgebase,                 % question generator
        call_goal_parameters,                   % examines all goal parameters
        presentation_result.             % presents the result
changed_consultation:-
        retractall(trigged(_,_,_)),
        retractall(how(_,_,_,_)),
        create_knowledgebase,                % question generatoer
        call_goal_parameters.                   % examines all goal parameters

% Reads a file with answers and gives possibilities to change answers.

% Saves answers and complete session on file.
store_answers:-
		\+tcl_GUI(on),
        write('Give a file name: '),
        read(Filename),
        tell(Filename),
        write(':-dynamic answer/2.'),nl,        
        listing(answer),nl,
        told.
%Built-in function in tcl/tk tk_getSaveFile that create a 
%window where the user can choose where to save a file on computer		
store_answers:-
		tcl_GUI(on),
		%Source = 'source k:/kl�ver/fetchfile.tcl',
		%run_tcl(Source, Filename),
		%retract_and_destroy(Filename),
		tcl(Tcl),
		tcl_eval(Tcl,['tk_getSaveFile -defaultextension ".pl" -filetypes {{{Perl Files} {.pl} TEXT} {{Text Files} {.txt}  TEXT} {{Text Files} {""} TEXT}}'],File),
		(
		File == [],!,
		fail
		;
		atom_codes(Filename, File),
        tell(Filename),
        write(':-dynamic answer/2.'),nl,        
        listing(answer),nl,
        told).
		%tcl_delete(Tcl).
		
store_session:-
		\+tcl_GUI(on),
        write('Give a file name: '),
        read(Filename),
        tell(Filename),
        write(':-dynamic how/4,answer/2,trigged/3.'),nl,        
        listing(answer),
        listing(trigged),
        listing(how),nl,
        told.
%Built-in function in tcl/tk tk_getSaveFile that create a 
%window where the user can choose where to save a file on computer			
store_session:-
        tcl_GUI(on),
		%Source = 'source k:/kl�ver/fetchfile.tcl',
		%run_tcl(Source, Filename),
		%retract_and_destroy(Filename),
        tcl(Tcl),
		tcl_eval(Tcl,['tk_getSaveFile -defaultextension ".pl" -filetypes {{{Perl Files} {.pl} TEXT} {{Text Files} {.txt}  TEXT} {{Text Files} {""} TEXT}}'],File),
		(
		File == [],!,
		fail
		;
		atom_codes(Filename, File),
		tell(Filename),
        write(':-dynamic how/4,answer/2,trigged/3.'),nl,        
        listing(answer),
        listing(trigged),
        listing(how),nl,
        told).
		%tcl_delete(Tcl).
		
read_answerfile:-
		\+tcl_GUI(on),
        write('The name of the file is: '),
        read(Filename),
        consult(Filename).
%Built-in function in tcl/tk tk_getOpenFile that create a 
%window where the user can choose a file on computer			
read_answerfile:-
        tcl_GUI(on),
		tcl(Tcl),
		tcl_eval(Tcl,['tk_getOpenFile -filetypes {{{Perl Files} {.pl} TEXT} {{Text Files} {.txt}  TEXT} {{Text Files} {""} TEXT}}'],File),
		(
		File == [],!,
		fail
		;
		atom_codes(Filename, File),
		retractall(answer(_,_)),
        retractall(trigged(_,_,_)),
        retractall(how(_,_,_,_)),
		%Source = 'source k:/kl�ver/fetchfile.tcl',
		%run_tcl(Source, Filename),
		%retract_and_destroy(Filename),
		consult(Filename)).
		
% Fetches list of goal parameters from KB and checks them.
call_goal_parameters:-
                goal_conclusions(List),     
                check_all(List).         

% Conditionless examination of all goal paramameters.
check_all([]).
check_all([Parameter|Rest]):-
                check(Parameter,_, goal_parameter,_),  
                check_all(Rest).
check_all([Parameter|Rest]):-
                assert(trigged(Parameter, Attribute, 0)),  
                check_all(Rest).        

% ***************************************************
% General predicates used for tcl_tk GUI

% abort tcl and sicstus if user closed the tcl/tk window
tcl_abort_case([]):-
		tcl(Tcl),
		tcl_delete(Tcl),
		abort,!.
tcl_abort_case(Var).

% load a new tcl window, and then waits for a user-event from tcl side
run_tcl(Source, Event):-
	tcl(Tcl),
	tcl_eval(Tcl,Source,_),
	tk_next_event(Tcl, Event).

%retract asserted facts, and remove tcl window 	
retract_and_destroy(Event):-
		tcl(Tcl),
		delete_tcl_facts,
		tcl_abort_case(Event),!,
		tcl_eval(Tcl,'destroy .t',_).

%total clean-up of asserted data used for tcl GUI		
delete_all_tcl:-
	retractall(answer_options(_)),
	retractall(num_answers(_)),
	retractall(tcl_question(_,_,_,_,_)),
	retractall(attr_cf(_,_,_)),
	retractall(num_attr_cf(_,_)).
	
delete_tcl_facts:-
	retractall(answer_options(_)),
	retractall(num_answers(_)),
	retractall(tcl_question(_,_,_,_,_)).
	
%converts a string to an integer
string_to_integer(Ans, Int):-
	atom_codes(Ans,ASCII_List),!, 
	name(Int,ASCII_List).

%A list in tcl is a string where elements are separated by empty space
%This predicate transforms the string to a list of ascii-numbers	
tcl_list_to_prolog_list(Atom,Answers):-
	atom_codes(Atom, ASCII),
	remove_spaces(ASCII, Answers).

%create new ascii-list without empty spaces (ascii nr 32) 	
remove_spaces([],[]).
remove_spaces([32|List], Rest):-
	remove_spaces(List,Rest).
remove_spaces([E|List], [E|Rest]):-
	remove_spaces(List,Rest).

%assert_each_option/1: assert each element in list 
%asserted facts are used by tcl_tk to retrieve answers from Prolog without deleting original answer.
assert_each_option([]).
assert_each_option([E|Rest]):-		
			assert(answer_options(E)), 
			assert_each_option(Rest).

%assert_num_options(+AnswerList): count elems in list and assert number
%this fact is used by tcl_tk 
assert_num_options(X):-
	count_elems(X,Num),!,
	assert(num_answers(Num)).

%retract_predicate/2 is needed to be able to retract temporarily facts in kl�ver from tcl_tk side
retract_answer(Num,M):-
	retract(answer_options(_)).
	
retract_number:-
	retract(num_answers(_)).
	
% For TCL: Assert all conclusions set to 'true' which means  
% they have propability > 100
assert_attr_list(_,[]).		
assert_attr_list(Object,[(Attribute, Value)|Rest]):-
        tcl_GUI(on),
		assert(attr_cf(Object,Attribute, Value)),
        assert_attr_list(Object,Rest).
		
retract_attr_list(Object):-
	retract(attr_cf(Object,_,_)).

assert_num_attributes(Object, AttrList):-	
		count_elems(AttrList,Num),!,
		assert(num_attr_cf(Object,Num)).

%get_single_answer/3 
%retrieve the element on "index place" in a list.
get_single_answer(0, [Ans|_], Ans).
get_single_answer(Num, [E|Rest], Ans):-
		Num1 is Num - 1,
		get_single_answer(Num1, Rest, Ans).

%get_answer_list/3 convert each ASCII-nr to integer, retrieve and store each object in new list 
get_answer_list(_, [], []).
get_answer_list(Options, [ASCII|Rest], [A|List]):-
	name(Int,[ASCII]),
	get_single_answer(Int, Options, A),
	get_answer_list(Options, Rest, List).

convert_to_objects([], []).
convert_to_objects([(A,V)|Rest], [A|New]):-
		convert_to_objects(Rest, New).
	
% **************************************************
% ************* Inference mechanism *****************


% Checks the control of all conditions in the knowledge base:
% (Not system related conditions.)

% when given answer exists
check(Object, Condition, Value):-
        answer(Object,Answer),
        check_condition(Object, Condition, Value).

% when the value is set by rules
check(Object, Attribute, Condition, CF):-
        trigged(Object, Attribute, CF2),
        check_condition(Object, Attribute, Condition, CF).

% Checks true and false on conclusions set by rules.
check(Object, Attribute, Truth_value) :-        
        (Truth_value = sant; Truth_value = falskt),
        trigged(Object, Attribute, CF),
        check_condition(Object, Attribute, Truth_value).

% Asks questions that have not been asked by the question generator and possible 
%follow-up questions. Main question conditionless and follow-up questions with conditions.

check(Object,Condition, Value):-
		tcl_GUI(on),
         \+ answer(Object,_),
        question_info(Object, Prompt, Meny, Type, Fragevillkor ),
                question_condition(Fragevillkor,Back),
		%assert(tcl_question(Object, Prompt, Meny, Type, _)),
        type_control(Type, Object),
		%retract(tcl_question(Object, Prompt, Meny, Type, _)),
		((question_sequence(Object, Foljdfragelista),
        ask_user(Foljdfragelista)) ; true), !,
        check_condition(Object, Condition, Value).
		
check(Object,Condition, Value):-
		\+ tcl_GUI(on),
         \+ answer(Object,_),
        question_info(Object, Prompt, Meny, Type, Fragevillkor ),nl,
                question_condition(Fragevillkor,Back),
        write(Object),nl,
        write(Prompt),nl,
        menue_write(Meny),nl,
        write('Enter Why if you want a text based explanation. Then answer the question!'),nl,nl,
        type_control(Type, Object),
        ((question_sequence(Object, Foljdfragelista),
        ask_user(Foljdfragelista)) ; true), !,
        check_condition(Object, Condition, Value).

% Goes through all rules for objects that can be determined by rules but have yet not
% been evalutated.
check(Object,  Attribute, Condition, Value):-
        \+ how(_,Object, Attribute, _),
        rule_info(Object, Rule_numbers),
        solve_all(Object, Rule_numbers,Partial_answer, Answer),!,
        check_condition(Object, Attribute,  Condition, Value).

% Checks rules for conditions with true and false.
check(Object,  Attribute,  Truth_value):-
        \+ how(_,Object, Attribute, _),
        rule_info(Object, Rule_numbers),
        solve_all(Object, Rule_numbers,Partial_answer, Answer),!,
        check_condition(Object, Attribute, Truth_value).


% No more rules for the object.
solve_all(Object, [], Answer, Answer).
%Ruels that set an object-attribute combination to a value
% that has proven completely true or completely false do not affect the truth value.
solve_all(Object, [FR|RR], Partial_answer, Answer):-
        (trigged(Object, Attribute, 1000);
        trigged(Object, Attribute, -1000)),
        clause(rule(FR,Object, Attribute, CF), Condition) ,
        solve_all(Object, RR, Partial_answer, Answer).
% Examines the first rule in the rules list, if succseeded CF is updated and 
% we move on to the rest of the list.
solve_all(Object, [FR|RR], Partial_answer, Answer):-
        rule(FR,Object, Attribute, CF),
         update_CF(FR,Object, Attribute, CF, Partial_answer, New_partial_answer),
        solve_all(Object, RR, New_partial_answer, Answer).
% If the rule failes the result is stored as rule rejected.
% this in order to inform that the object has been examined even if no rule succeeded.
solve_all(Object, [FR|RR], Partial_answer,Answer):-
        clause(rule(FR,Object,Attribute,CF),Premises), % to bind the attribute
        asserta(how(FR,Object,Attribute,rejected)), 
        solve_all(Object, RR, Partial_answer, Answer).
		
solve_all(Object, [FR|RR], Partial_answer,Answer):-
		\+ rule(FR,Object,_,_),
		solve_all(Object,RR,Partial_answer,Answer).

% check_condition controls that the condition in the check really is fullfilled 
% by the value that the object and attribute has been alocated.

% All goal parameters are to be checked.
check_condition(Object,_, goal_parameter,_).

% The followin is applicated on user given answers.
check_condition(Object, = , Value):-
        !,
        answer(Object,Value).
check_condition(Object, >=, Value1):-
        answer(Object, Value2), 
        number(Value2),
        Value2 >= Value1.
check_condition(Object,>,Value1):-
        answer(Object,Value2),
        number(Value2),
        Value2 > Value1.
check_condition(Object,=<,Value1):-
        answer(Object,Value2),
        number(Value2),
        Value2 =< Value1.
check_condition(Object,<, Value1):-
        answer(Object, Value2), 
        number(Value2),
        Value2 < Value1.
check_condition(Object,'<>',Value):-
        \+ answer(Object,Value).

% The followeing is applicated on conclusions drawn by the system.
% The following two cases are applied on conclusions and will compare their 
% certainty factors with a specific value.
check_condition(Object, Attribute,   'cf>=', CF1):-
        trigged(Object,Attribute,CF2),!,
        number(CF2),   
        CF2 >= CF1.
check_condition(Object, Attribute,   'cf<' , CF1):-
        trigged(Object,Attribute,CF2),!,
        number(CF2),
        CF2 < CF1.

% The following three will check the conclusions drawn by numeric rules for example  
% belopp_guld and compares given value with another value.
check_condition(Object, Attribute,   'Value>=', Value):-
        trigged(Object,Attribute,CF),        
        number(Attribute),
        Attribute >= Value.
check_condition(Object, Attribute,   'Value<', Value):-
        trigged(Object,Attribute,CF),
        number(Attribute),
        Attribute < Value.
check_condition(Object, Attribute,  'Value=', Value):-
        trigged(Object,Attribute,CF),
        number(Attribute),
        Attribute = Value.
% To make is easier to check if conclusions are completely true or false. 
check_condition(Object, Attribute, sant):-
        trigged(Object,Attribute,1000).
check_condition(Object, Attribute, falskt):-
        trigged(Object,Attribute,-1000).
% Takes care of conditions on the form "least n of the following" for conclusions.
check_condition(Object, Less_num,outof ,Attribute_list):-
        count_attribute(Object,Attribute_list,Num_in_list), 
        Num_in_list >= Less_num.
% Takes care of conditions on the form "least n of the following" for user given info.
check_condition(Object, Less_num, Attribute_list):-
        count_attribute(Object,Attribute_list,Num_in_list), 
        Num_in_list >= Less_num.

% Calculates number of attributes for an object that exist in a list.
% Called by check_condition for that type of condition.
count_attribute(Object,[],0).
count_attribute(Object,[Attribute| Rest],Number):-
        (check(Object, =, Attribute) ;
         check(Object,Attribute, 'cf>=',1000)),!,
        count_attribute(Object,Rest,Number1),
        Number is Number1 + 1.
count_attribute(Object,[Attribute|Rest],Number):-
        count_attribute(Object,Rest,Number).

% ***********************************************
% *********** Certainity handling ***************

% Saves CF for an attribute for the first time.
update_CF(Regelnr, Object, Attribute, CF, [], [(Attribute, CF)]):-
        asserta(trigged(Object, Attribute, CF)),
        asserta(how(Regelnr, Object, Attribute, CF)). 
% Keeps the rule that has been shown 
% and its CF for use with "how"-questions
% The attribute has not been shown by any former rule because it does not exist in the
% list Partial_answer. Therefore given CF for the attribute is saved.
update_CF(Regelnr,Object, Attribute, CF, Partial_answer,[(Attribute, CF)|Partial_answer] ):-
        not_memb((Attribute, X), Partial_answer),
        asserta(trigged(Object, Attribute, CF)),
        asserta(how(Regelnr, Object, Attribute, CF)).


% Attribute proven completely true or completely false before.
% Possible new rules do not affect this.
update_CF(Regelnr, Object, Attribute, CF, Partial_answer, Partial_answer ):-
        memb((Attribute, X), Partial_answer),
        (trigged(Object, Attribute, 1000);
                trigged(Object, Attribute, -1000)),!.

% Attribute given CF before. New CF is always to be 
% calculated as a contexture of the new and the old value.
update_CF(Regelnr, Object, Attribute, CF, Partial_answer, New_partial_answer ):-
        memb((Attribute, X), Partial_answer),
        calculate_CF((Attribute, CF), Partial_answer, New_partial_answer, New_CF),
        retract(trigged(Object, Attribute, Old_CF)),  % earlier CF deleted
        asserta(trigged(Object, Attribute, New_CF)), % combined CF lagras
        asserta(how(Regelnr, Object, Attribute, New_CF)). % info for "how"-questions%

% Calculates CF as a contexture of old and new value.
% All attributes and their CF are stored in a list as arguments.
% to the predcate. Current predicate first in list.
calculate_CF((Attribute, CF), [(Attribute, Old_CF)|Partial_answer],
           [(Attribute, New_CF)|Partial_answer], New_CF):-
        cf(CF, Old_CF, New_CF).

% Current predicate not first in list. 
% Continue to go through list Partial_answer to find it.
calculate_CF((Attribute, CF), [(X, Y)|Partial_answer], [(X,Y) | New_partial_answer], New_CF):-
        Attribute \== X,
        calculate_CF((Attribute, CF), Partial_answer, New_partial_answer, New_CF).

% Contexture of CF. Both new and old value for CF < 0.
cf(CF, Old_CF, New_CF):-
        Old_CF < 0, CF < 0, !,
        New_CF is Old_CF + ((CF * (1000 + Old_CF )) // 1000).
% Both new and old value for CF >= 0.
cf(CF, Old_CF, New_CF):-
        Old_CF >= 0, CF >= 0, !,
        New_CF is Old_CF + (( CF * (1000 - Old_CF)) // 1000).
% One of the values for old or new CF < 0.
cf(CF, Old_CF, New_CF):-
        min(CF, Old_CF, Min_CF),
        New_CF is (((CF + Old_CF) * 1000)// (1000 - Min_CF)).

% Minimum of two values for CF.
min(CF1, CF2, ACF1):-
        abs_value(CF1,ACF1),
        abs_value(CF2,ACF2),
        ACF1 < ACF2.
min(CF1, CF2, ACF2):-
        abs_value(CF1,ACF1),
        abs_value(CF2,ACF2),
        ACF2 =< ACF1.

abs_value(CF,CF):-
        CF >= 0.
abs_value(CF1,CF2):-
        CF1 < 0,
        CF2 is -1*CF1.

% *************************************************
% ************* Various predicates ****************

not_memb((Attribute, X), Partial_answer):- 
        memb((Attribute, X), Partial_answer),!,
        fail.

not_memb((Attribute, X), Partial_answer).

equal(Attribute,Solution):-
        Attribute == Solution.

memb(Elem,[Elem | List]):- !.
memb(Elem,[X | List]):-
        memb(Elem,List).

'<ERROR>'(2) :- !, fail.

clean:-
        retractall(answer(_,_)),
        retractall(trigged(_,_,_)).

%*****************************************************************        
%*****************************************************************        
% Window 2 - Generates questions


% **************************************************
% ************* Question generator *****************

:-dynamic goal_temp/1,how/4,question_temp/1,menu_temp/1,menu_temp/2,ok/1,redo/1,answer/2,temp/1,text/2,trigged/3.

% Examines all introducing questions.
create_knowledgebase:-
        question_order(List),
        ask_user(List).

% When going backwards in questioning or with "redo" as condition on a question.
create_database:-
        redo(true),
        retractall(redo(true)),
        create_database.

% Examins wether a question is to be asked and then asks the question.
ask_user([]).
ask_user([Object| Rest]):-
        answer(Object,Answer),!,
        ask_user(Rest).
%GUI deactivated
ask_user([Object| Rest]):-
        \+tcl_GUI(on),
		question_info(Object,Prompt,Meny,Type,Condition),
        question_condition(Condition,Back),
        write(Object), nl,
        write(Prompt),nl,
        menue_write(Meny),nl,
        write('Print Why if you want an explanation. Then answer the question!'),nl,nl,
        type_control(Type, Object),
        back_check(Back),!,
        ask_user(Rest).
%GUI activated		
ask_user([Object|Rest]):-
		tcl_GUI(on),
        question_info(Object, Prompt, Meny, Type, Condition),
        question_condition(Condition,Back),
		%assert(tcl_question(Object, Prompt, Meny, Type, _)),
        type_control(Type, Object),
		%retract(tcl_question(Object, Prompt, Meny, Type, _)),
		back_check(Back),!,
        ask_user(Rest).
%GUI activated
% single answer questions
type_control(s, Object):-
        tcl_GUI(on),
		question_info(Object,Prompt,Options,Type,Condition),
		assert(tcl_question(Object, Prompt, Options, Type, _)),
		assert_each_option(Options),
		assert_num_options(Options),
		Source = 'source k:/kl�ver/s_questions.tcl',
		run_tcl(Source, Meny_Index),
		retract_and_destroy(Meny_Index),
		(
		Meny_Index = change_answers,
		run_option('Change answers'),
		changed_consultation;
		%type_control(s, Object);
		get_single_answer(Meny_Index, Options, Answer),
		arrange_answer(Object,Answer)).
%GUI activated
% w-questions where user write an arbitrary answer
type_control(w, Object):-
		tcl_GUI(on),
		question_info(Object,Prompt,Options,Type,Condition),
		assert(tcl_question(Object, Prompt, Options, Type, _)),
		Source = 'source k:/kl�ver/w_questions.tcl',
		run_tcl(Source, Answer),
		retract_and_destroy(Answer),
		(
		Answer = change_answers,
		run_option('Change answers'),
		changed_consultation;
		%type_control(w, Object);
		(
		string_to_integer(Answer, Int),
		arrange_answer(Object,Int);
		arrange_answer(Object, Answer))).	
%GUI activated
% multiple answers questions
type_control(m, Object):-
		tcl_GUI(on),
        question_info(Object,Prompt,Options,Type,Condition),
		assert(tcl_question(Object, Prompt, Options, Type, _)),
		assert_each_option(Options),
		assert_num_options(Options),
		Source = 'source k:/kl�ver/m_questions.tcl',
		run_tcl(Source,Event),
		retract_and_destroy(Event),
		(
		Event = change_answers,
		run_option('Change answers'),
		changed_consultation;
		%type_control(m, Object);
		tcl_list_to_prolog_list(Event,ASCII_Ans),
		get_answer_list(Options, ASCII_Ans, Answers), 
        store_one_answer(Object, Answers)).

%GUI deactivated
type_control(X, Object):-
		\+tcl_GUI(on),
        (X == s ; X == w),
        read(Answer),nl,
        arrange_answer(Object,Answer).
%GUI deactivated
type_control(Type, Object):-
		\+tcl_GUI(on),
        write('This question can be answered with multiple answers! '),
        nl,
        write('Please insert an answer and finish the insertion with the word stop. '), nl,
        read(Ans),
        read_all_answers(Object,Answers, Ans),
        store_one_answer(Object, Answers).

	
read_all_answers(Object,Answers,'Why'):-
        why_explanation(Object),!,
        read(Ans),
        read_all_answers(Object,Answers,Ans).
read_all_answers(Object,[], stop):- \+tcl_GUI(on), !.
read_all_answers(Object,[Ans|Answer], Ans):-
        read(New_answer),
        read_all_answers(Object,Answer, New_answer).

% When going backwards it will fail and it starts from the beginning.
ask_user(_):-
        redo(true),!,
        fail.
ask_user([Object| Rest]):-
        ask_user(Rest).

arrange_answer(Object,'Why'):-
        !,why_explanation(Object),
        read(New_answer),
        arrange_answer(Object,New_answer).
arrange_answer(Object,Answer):-
        store_one_answer(Object, Answer).

% Saves user-given answers as separate relations.
store_one_answer(Object, []).
store_one_answer(Object, [stop]).
store_one_answer(Object, [First|Rest]) :-
        asserta(answer(Object, First)),
        store_one_answer(Object, Rest).
store_one_answer(Object, Answer):-
        asserta(answer(Object, Answer)).

% When going backwards in a dialogue or with "redo" as question condition.
back_check(t):-
        asserta(redo(true)),!,
        fail.
back_check(f).

% Takes back all conclusions and makes new ones when going backwards in the dialogue.
revise_ev_concl:-
        ((trigged(_,_,_), retractall(trigged(_,_,_))) ;
        true),
        ((how(_,_,_,_) , retractall(how(_,_,_,_))) ;
        true),
        goal_conclusions(Goal_param_list),
        check_all(Goal_param_list).

% Conditions that can be put on questions in the question generator.
% "redo" makes back true and  back_check 
% will assert redo in the databasen and the complete fraga_ev_anvandaren will fail
% and the whole question base will be examined again, beautiful dont you think? Ever seen it before?
question_condition([redo],t).
% no conditions
question_condition([],f).
% not-condition
question_condition([not(Condition)| Rest], Go_back):-
        \+ single_condition(Condition),
        question_condition(Rest, Go_back).
% or-condition
question_condition([or(Condition1,Condition2) | Rest],Go_back):-
        or_condition([Condition1,Condition2]),
        question_condition(Rest,Go_back).
% Only single questions. (No composed questions.)
question_condition([Condition | Rest],Go_back):-
        single_condition(Condition),
        question_condition(Rest, Go_back).

% Control of single question conditions.
or_condition([Condition | Rest]):-
        question_condition([Condition],_).

or_condition([Condition | Rest]):-
        or_condition(Rest).

single_condition((Object = Answer)):-
        answer(Object,Argument),
	equal(Argument,Answer).

single_condition((Object > Value)):-
        answer(Object, Answer),
        Answer > Value.

single_condition((Object < Value)):-
        answer(Object, Answer),
        Answer < Value.

single_condition((Object >= Value)):-
        answer(Object, Answer),
        Answer >= Value.

single_condition((Object =< Value)):-
        answer(Object, Answer),
        Answer =< Value.

single_condition((Object = Value)):-
        answer(Object, Answer),
        Answer == Value.

single_condition((Object > Value)):-
        answer(Object, Answer),
        Answer > Value.

%*****************************************************************        
%*****************************************************************        
% Window 3 - Question base



%************************INFO ABOUT QUESTIONS**********************
% question_info/5.


% question_info/5.

%Questions to user

question_info(symptoms,'What symptoms is the patient showing',
      [pain,swelling,'Difficulty Moving', numbness, weakness, bump, other],m,[]).
question_info(affected_fingers,'Which fingers are affected',
      [1, 2, 3, 4, 5, none],m,[]).
question_info(movement_difficulty,'What movement difficulty is the patient having?',
      ['Finger stuck', 'Finger cannot straighten', 'Resistance in movement'],m,[symptoms= 'Difficulty Moving']).
question_info(pain_level,'What is the level of pain for the patient?',
      [low, medium, high, very_high, 'dont know'],s,[symptoms= pain]).
question_info(swelling_level,'What is the level of swelling on the patient?',
      [low, medium, high, very_high, 'dont know'],s,[symptoms= swelling]).		  
%add filters for thumb questions	  
question_info(area,'On which area of the hand are the symtoms',
      [dorsal, volar, ulnar_side, radial_side, 'not sure'],s,[]).
question_info(location,'On which part of the thumb are the symptoms',
      [ip,mp,cmc, thumb_tip,'More than one','Not sure'],s,[affected_fingers=1]).
question_info(specific_locations,'On which part of the thumb is are the symptoms',
      [ip,mp,cmc, thumb_tip],m,[location='More than one']).	
question_info(cause,'What is the cause of the injury/problem?',
      [trauma,overuse,'dont know'],s,[]).
question_info(overuse_type,'What kind of overuse caused the problem?',
      ['Overuse overtime','Excessive overuse','dont know'],s,[cause= overuse]).
question_info(trauma_type,'What was the cause of the trauma?',
      ['Infection from wound','Extreme inward bending of finger','Extreme outward bending of finger','Pressure on wrist','dont know'],s,[cause= trauma]).	  
question_info(since_when,'When did the injury happen?',
      ['less than a week ago','1 to 3 weeks ago','more than 3 weeks ago','dont know'],s,[]).
question_info(condition,'When do the symptoms appear?',
      ['When moving finger','Applying pressure on area','At specific times','Repeated action','dont know'],m,[]).
question_info(condition_moving,'What kind of movement affects the finger?',
      [grabbing,twisting,turning,'Key Grip',pinch,straighten],m,[condition='When moving finger']).
question_info(condition_time,'What time do the symptoms appear?',
      ['Always','Night time','Morning'],m,[condition='At specific times']).	
  

%Examination Tests

question_info(pressure_test,'What is the result of the pressure test?',
      ['Pain','No Pain','Dont know'],s,[area=volar,or(location=mp,specific_locations= mp)]).  						% WILL THIS WORK????
question_info(movement_test_1,'What is the result of the movement test?',
      ['Still stuck','No pain or resistance', 'Dont know'],s,[area=volar ,or(location= mp , specific_locations=mp)]).
question_info(angle_test_ulnar,'What is the result of the angle test?',
      ['Less than 45 degrees','More than 45 degrees', 'More than 60 degrees', 'dont know'],s,[area=ulnar_side, or(location=mp , specific_locations=mp)]).
question_info(visual_swelling_test,'Is the patients MP joint swollen?',
      ['Yes','No', 'Dont know'],s,[area=ulnar_side ,or(location=mp, specific_locations=mp)]).
question_info(angle_test_radial,'What is the result of the angle test?',
      ['Less than 45 degrees','More than 45 degrees', 'More than 60 degrees', 'dont know'],s,[area=radial_side , or(location=mp , specific_locations=mp)]).
question_info(visual_swelling_test,'Is the patients MP joint swollen?',
      ['Yes','No', 'Dont know'],s,[area=radial_side, or(location=mp, specific_locations=mp)]).
    
question_info(movement_test_2,'Can the OT straighten the fingertip?',
      ['Yes','No', 'Dont know'],s,[or(location=thumb_tip, specific_locations=thumb_tip)]).
  
question_info(little_finger_test,'What is the result of the little finger test?',
      ['Pain','No Pain', 'Dont know'],s,[location=cmc , specific_locations=cmc]).
question_info(radial_abducation_test,'What is the result of the Radial Abduction Test?',
      ['Pain','No Pain', 'Dont know'],s,[little_finger_test='No Pain']).
question_info(finkelstein_test,'What is the result of the Finkelstein test?',
      ['Pain','No Pain', 'Dont know'],s,[radial_abducation_test='No Pain']).
question_info(semmes_weinstein_test,'What is the result of the Semmes Weinstein test?',
      ['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4','Numbness in finger 5','Numbness in all fingers', 'Dont know'],m,[symptoms=numbness, area=volar]).
question_info(tinel_test,'What is the result of the Tinel test?',
      ['Fingers tingle','Fingers dont tingle', 'Dont know'],s,[symptoms=numbness, area=volar]).
question_info(phalen_test,'What is the result of the Phalen test?',
      ['Feeling in fingers change','Feeling in fingers doesnt change', 'Dont know'],s,[symptoms=numbness, area=volar]).
question_info(grind_test,'What is the result of the Grinding test?',
      ['Grinding sensation','No grinding senstion', 'Dont know'],s,[symptoms=bump , or(location=cmc , specific_locations=cmc)]).
question_info(visual_test,'Is the thumb bigger than the thumb on the other hand?',
      ['Yes','No', 'Dont know'],s,[symptoms=bump , or(location=cmc , specific_locations=cmc)]).
question_info(movement_test_3,'Can the patient place his hand straight on a flat surface?',
      ['Yes','No', 'Dont know'],s,[symptoms=bump , or(location=cmc , specific_locations=cmc)]).

%Additional Info
question_info(diabetes,'Does the patient have diabetes',
      ['Yes','No', 'Dont know'],s,[area=volar , or(location=mp , specific_locations=mp)]).
question_info(disease,'Which of these diseases does the patient have?',
      ['Rematoid arthritis','Gout','Pseudogout','Psorasis','None of them', 'Dont know'],m,[symptoms=bump , or(location=cmc , specific_locations=cmc)]).
question_info(heritage,'Does someone in the patients family have arthritis',
      ['Yes','No', 'Dont know'],s,[symptoms=bump , or(location=cmc , specific_locations=cmc)]).  




% Questions to be asked by the question gerator.
% question_order/1.

question_order([symptoms,pain_level, swelling_level, movement_difficulty,
 affected_fingers,location,specific_locations,pressure_test,little_finger_test, movement_test_1,movement_test_2,movement_test_3, angle_test_ulnar,angle_test_radial,visual_test,visual_swelling_test,grind_test,
 area,phalen_test,tinel_test, cause, trauma_type, overuse_type, since_when,
 condition,condition_moving, condition_time]).


% Follow-up questions that could be asked when a question is
% generated from the knowledge base.

/*question_sequence(symptoms,[pain_level, swelling_level, movement_difficulty,
 affected_fingers,location,specific_locations,pressure_test,little_finger_test, movement_test_1,movement_test_2,movement_test_3, angle_test_ulnar,angle_test_radial,visual_test,visual_swelling_test,grind_test,
 area,phalen_test,tinel_test, 
 cause, trauma_type, overuse_type,
 since_when,
 condition,condition_moving, condition_time ]).
 

question_sequence(affected_fingers,[location]).
question_sequence(area,[phalen_test, pressure_test,movement_test_1,tinel_test,angle_test_ulnar,visual_swelling_test,angle_test_radial]).
question_sequence(cause,[trauma_type, overuse_type]).
question_sequence(condition,[condition_moving, condition_time]).
question_sequence(location,[specific_locations,pressure_test,little_finger_test, movement_test_1,movement_test_2,movement_test_3, angle_test_ulnar,angle_test_radial,visual_test,visual_swelling_test,grind_test]).
question_sequence(little_finger_test,[radial_abducation_test]).
question_sequence(radial_abducation_test,[finkelstein_test]).*/
question_sequence(_, []).  % for all questions without follow-up questions. 
%question_sequence(capital,[revenuetime]).


definition(symptoms,'These are Indications of a possible existing condition.').
definition(affected_fingers,'Which fingers wre showing the selected symptoms.').
definition(movement_difficulty,'What kind of movement difficulty is the patient having').
definition(pain_level,'What level of pain is the patient experiencing').
definition(swelling_level,'How bad is the swelling on the patient in comparison to the normal hand').
definition(area,'This is the general are of the hand that is affected by the symptoms').
definition(location,'Trading with diamonds require trustworthy companies to rely upon. This applies to a lesser extent to other fields aswell. ').
definition(specific_locations,'These are the specific parts of the finger that are affected by the symptoms.').
definition(cause,'How the injury coild have come about.').
definition(overuse_type,'In what way was the hand7 finger overused ').
definition(trauma_type,'What kind of trauma was experienced to cause the injury').
definition(since_when,'This is the time since the symptoms started showing ').
definition(condition,'These are the conditions that cause the symptoms to show ').
definition(condition_moving,'This is the kind of movement that causes the undesired symptoms to show').
definition(condition_time,'This is to evaluate whether the symptoms only appear at a specific time').
%Examination definitions
definition(pressure_test,'When patient relaxes ').
definition(movement_test_1,'OT moves thumb check if there is 1- no pain or resistance 2- still stuck.').
definition(movement_test_2,'Try to straighten thumbtip').
definition(movement_test_3,'Can the patient place their palm straight on a flat surface ').
definition(angle_test_radial,'OT holds hand on both sides of the MP joint. Thumb side hand bends towards the wrist. Measure angle over joint.').
definition(visual_swelling_test,'The pace of the inflation will affect where to best place your money.').
definition(little_finger_test,'Place hand volar side on surface, put resistance against little finger, ask patient to push against resistance. ').
definition(radial_abducation_test,'Rest fist on surface with little finger side down, OT pushes against thumb, Patient has to push against resistance. ').
definition(finkelstein_test,'Fist with thumb inside hand and little finger side down, patient should move wrist up and down').
definition(semmes_weinstein_test,'On all fingers, numbness in 1-4 not in 5.').
definition(tinel_test,'Tapping the median nerve over the volar carpal tunnel. If thinger tingles it�s positive. ').
definition(phalen_test,'Wrist volar flexion for 60 secs produces symptoms. Feeling in the fingers changes.').
definition(grind_test,'Grinding sensation when thumb is moved.').
definition(visual_test,'Thumb bigger than other hand').



%*****************************************************************        
%*****************************************************************        
% Window 4 - Question base

goal_conclusions/1.

goal_conclusions([diagnosis,treatment]).

% to_present/1.

to_present([diagnosis,treatment]).

% information about conclusions drawn by rules.

% rule_info/2.

rule_info(diagnosis,
        [10,11,12,13,14,15,16,20,21,22,23,24,25,30,31,32,33,34,40,41,42,43,45,44,50,51,52,53,54,55,56,57,60,61,62,63,64,65,70,71,72,73,74,75,80,81,82,83,84,85,86,87]).
		
% changed rule_info

rule_info(treatment,[100,101,102,103,104,110,111,112,113,114,115,116,117,118,120,121,122,130,140,141,142,150,151,160,161,170,171,172,1000,1001,1002,1003,1004,1110,1111,1112,1113,1114,1115,1116,1117,1118,1200,1201,1202,1300,1400,1401,1402,1500,1501,1600,1601,1700,1701,1702,1703]).




%*****************************************************************        
%*****************************************************************        
% Window 5 - Rules base

% rule/4.
:- dynamic rule/4.  %To be able to use clause on the rule.


% rules for Trigger Finger

rule(10,diagnosis,trigger_finger,1000):-
        check(symptoms,2,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(movement_difficulty,1,['Finger stuck','Resistance in movement']),
		check(area,=,volar),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,2,['When moving finger','Applying pressure on area']),
		check(pressure_test,=,'Pain'),
		(check(movement_test_1,=,'Still stuck');check(movement_test_1,=,'No pain or resistance')).
		
rule(11,diagnosis,trigger_finger,700):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(area,=,volar),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger','Applying pressure on area']),
		check(pressure_test,=,'Pain'),
		(check(movement_test_1,=,'Still stuck');check(movement_test_1,=,'No pain or resistance')).


rule(12,diagnosis,trigger_finger,400):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(area,=,volar),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger','Applying pressure on area']).

rule(13,diagnosis,trigger_finger,600):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(area,=,volar),
		(check(location,=,mp);check(specific_locations,1,[mp])),		
		check(condition,1,['When moving finger','Applying pressure on area']),
		check(pressure_test,=,'Pain'),
		(check(movement_test_1,=,'Still stuck');check(movement_test_1,=,'No pain or resistance')).		

rule(14,diagnosis,trigger_finger,200):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(area,=,volar),		
		check(condition,1,['When moving finger','Applying pressure on area']).			

rule(15,diagnosis,trigger_finger,100):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),			
		check(condition,1,['When moving finger','Applying pressure on area']).
				
rule(16,diagnosis,trigger_finger,600):-
        check(symptoms,1,[pain, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger','Applying pressure on area']).

		
% rules for Skiing Thumb

rule(20,diagnosis,skiing_thumb,1000):-
        check(symptoms,3,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),
		check(area,=,ulnar_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme outward bending of finger']),
		check(condition,1,['When moving finger']),
		check(condition_moving,3,[grabbing,twisting,turning,'Key Grip',pinch,straighten]),
		(check(angle_test_ulnar,=,'More than 45 degrees');check(angle_test_ulnar,=,'More than 60 degrees')).

rule(21,diagnosis,skiing_thumb,900):-
        check(symptoms,2,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),
		check(area,=,ulnar_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme outward bending of finger']),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch,straighten]),
		(check(angle_test_ulnar,=,'More than 45 degrees');check(angle_test_ulnar,=,'More than 60 degrees')).

rule(22,diagnosis,skiing_thumb,800):-
        check(symptoms,1,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),
		check(area,=,ulnar_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme outward bending of finger']),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting,turning,'Key Grip',pinch,straighten]),
		(check(angle_test_ulnar,=,'More than 45 degrees');check(angle_test_ulnar,=,'More than 60 degrees')).

rule(23,diagnosis,skiing_thumb,600):-
        check(symptoms,1,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme outward bending of finger']),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting,turning,'Key Grip',pinch,straighten]).
		
rule(24,diagnosis,skiing_thumb,400):-
        check(symptoms,1,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),
		check(area,=,ulnar_side),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme outward bending of finger']),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting,turning,'Key Grip',pinch,straighten]).
		
rule(25,diagnosis,skiing_thumb,200):-
        check(symptoms,1,[pain, swelling,weakness]),
		check(affected_fingers,1,[1]),		
		check(area,=,ulnar_side),
		(check(location,=,mp);check(specific_locations,1,[mp])).		

% rules for De Quervain

rule(30,diagnosis,de_Quervain,1000):-
        check(symptoms,2,[pain, swelling]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting]),
		(check(little_finger_test,=,'Pain');check(radial_abducation_test,=,'Pain');check(finkelstein_test,=,'Pain')).

rule(31,diagnosis,de_Quervain,800):-
        check(symptoms,1,[pain, swelling]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting]),
		(check(little_finger_test,=,'Pain');check(radial_abducation_test,=,'Pain');check(finkelstein_test,=,'Pain')).
		
rule(32,diagnosis,de_Quervain,600):-
        check(symptoms,1,[pain, swelling]),
        check(affected_fingers,1,[1]),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting]).

rule(33,diagnosis,de_Quervain,500):-
        check(symptoms,1,[pain, swelling]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing,twisting]),
		(check(little_finger_test,=,'Pain');check(radial_abducation_test,=,'Pain');check(finkelstein_test,=,'Pain')).

rule(34,diagnosis,de_Quervain,400):-
        check(symptoms,1,[pain, swelling]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])).		
		
		
% rules for Extensor tendon Injury

rule(40,diagnosis,mallet_finger,1000):-
        check(symptoms,3,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(movement_difficulty,1,['Finger cannot straighten']),
		(check(location,=,thumb_tip);check(specific_locations,1,[thumb_tip])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme inward bending of finger','Extreme outward bending of finger']),
		check(condition,2,['When moving finger','Applying pressure on area']),
		check(movement_test_2,=,'Yes').

rule(41,diagnosis,mallet_finger,800):-
        check(symptoms,2,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		(check(location,=,thumb_tip);check(specific_locations,1,[thumb_tip])),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme inward bending of finger','Extreme outward bending of finger']),
		check(condition,2,['When moving finger','Applying pressure on area']),
		check(movement_test_2,=,'Yes').

rule(42,diagnosis,mallet_finger,600):-
        check(symptoms,2,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		(check(location,=,thumb_tip);check(specific_locations,1,[thumb_tip])),
		check(condition,2,['When moving finger','Applying pressure on area']),
		check(movement_test_2,=,'Yes').

rule(43,diagnosis,mallet_finger,300):-
        check(symptoms,2,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		check(cause,=,trauma),
		check(trauma_type,1,['Extreme inward bending of finger','Extreme outward bending of finger']),
		check(condition,1,['When moving finger','Applying pressure on area']).

rule(44,diagnosis,mallet_finger,200):-
        check(symptoms,1,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		(check(location,=,thumb_tip);check(specific_locations,1,[thumb_tip])),
		check(condition,1,['When moving finger','Applying pressure on area']),
		check(movement_test_2,=,'Yes').

rule(45,diagnosis,mallet_finger,100):-
        check(symptoms,1,[pain,swelling, 'Difficulty Moving']),
        check(affected_fingers,1,[1]),
		(check(location,=,thumb_tip);check(specific_locations,1,[thumb_tip])).
		
% rules for Carpal Tunnel Syndrome or Medial Nerve Compression
rule(50,diagnosis,carpal_tunnel_syndrome,1000):-
        check(symptoms,2,[numbness,weakness]),
        check(affected_fingers,4,[1,2,3,4]),
		check(area,=,volar),
		check(specific_locations,1,[thumb_tip]),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['At specific times','Repeated action']),
		check(condition_time,2,['Morning','Repeated action']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).

rule(51,diagnosis,carpal_tunnel_syndrome,800):-
        check(symptoms,1,[numbness,weakness]),
        check(affected_fingers,4,[1,2,3,4]),
		check(area,=,volar),
		check(specific_locations,1,[thumb_tip]),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['At specific times','Repeated action']),
		check(condition_time,2,['Morning','Repeated action']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).

rule(52,diagnosis,carpal_tunnel_syndrome,700):-
        check(symptoms,1,[numbness,weakness]),
        check(affected_fingers,4,[1,2,3,4]),
		check(area,=,volar),
		check(specific_locations,1,[thumb_tip]),
		check(condition,1,['At specific times','Repeated action']),
		check(condition_time,2,['Morning','Repeated action']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).

rule(53,diagnosis,carpal_tunnel_syndrome,650):-
        check(symptoms,2,[numbness,weakness]),
        check(affected_fingers,4,[1,2,3,4]),
		check(area,=,volar),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['At specific times','Repeated action']),
		check(condition_time,2,['Morning','Repeated action']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).
	
rule(54,diagnosis,carpal_tunnel_syndrome,600):-
        check(symptoms,2,[numbness,weakness]),
		check(specific_locations,1,[thumb_tip]),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		check(condition,1,['At specific times','Repeated action']),
		check(condition_time,2,['Morning','Repeated action']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).

rule(55,diagnosis,carpal_tunnel_syndrome,400):-
        check(symptoms,1,[numbness,weakness]),
        check(area,=,volar),
		check(specific_locations,1,[thumb_tip]),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).		

rule(56,diagnosis,carpal_tunnel_syndrome,200):-
        check(symptoms,1,[numbness,weakness]),
       	check(area,=,volar),
		check(cause,=,overuse),
		check(overuse_type,1,['Overuse overtime','Excessive overuse']),
		(check(semmes_weinstein_test,4,['Numbness in finger 1','Numbness in finger 2','Numbness in finger 3','Numbness in finger 4']);check(tinel_test,=,'Fingers tingle');check(phalen_test,=,'Feeling in fingers changes')).

rule(57,diagnosis,carpal_tunnel_syndrome,100):-
        check(symptoms,1,[numbness,weakness]),		
		check(specific_locations,1,[thumb_tip]),
		check(area,=,volar).
		
% rules for MP joint athritis
rule(60,diagnosis, mp_joint_athritis,1000):-
        check(symptoms,4,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(movement_difficulty,1,['Resistance in movement']),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing]).

rule(61,diagnosis, mp_joint_athritis,800):-
        check(symptoms,2,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing]).		

rule(62,diagnosis, mp_joint_athritis,600):-
        check(symptoms,2,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing]).

rule(63,diagnosis, mp_joint_athritis,500):-
        check(symptoms,2,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger']),
		check(condition_moving,1,[grabbing]).

rule(64,diagnosis, mp_joint_athritis,400):-
        check(symptoms,2,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')).

rule(65,diagnosis, mp_joint_athritis,100):-
        check(symptoms,2,[pain, 'Difficulty Moving', swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])).
		
				
		
% rules for CMC joint Athritis
rule(70,diagnosis,cmc_joint_athritis,1000):-
        check(symptoms,2,[pain, bump]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger','At specific times']),
		check(condition_moving,2,[grabbing, pinch,'Key Grip',turning]),
		check(condition_time,1,['Night time', 'Always']),
		(check(grind_test,=,'Grinding sensation');check(visual_test,=,'Yes')).

rule(71,diagnosis,cmc_joint_athritis,800):-
        check(symptoms,2,[pain, bump]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger','At specific times']),
		check(condition_moving,2,[grabbing, pinch,'Key Grip',turning]),
		check(condition_time,1,['Night time', 'Always']).

rule(72,diagnosis,cmc_joint_athritis,700):-
        check(symptoms,2,[pain, bump]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		check(condition,1,['When moving finger','At specific times']),
		check(condition_moving,2,[grabbing, pinch,'Key Grip',turning]),
		check(condition_time,1,['Night time', 'Always']).

rule(73,diagnosis,cmc_joint_athritis,400):-
        check(symptoms,1,[pain, bump]),
        check(affected_fingers,1,[1]),		
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')),
		check(condition,1,['When moving finger','At specific times']),
		check(condition_moving,2,[grabbing, pinch,'Key Grip',turning]),
		check(condition_time,1,['Night time', 'Always']).

rule(74,diagnosis,cmc_joint_athritis,650):-
        check(symptoms,2,[pain, bump]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])),
		(check(cause,=,overuse);check(cause,=,trauma)),
		(check(trauma_type,=,'Infection from wound');check(overuse_type,=,'Overuse overtime');check(overuse_type,=,'Excessive overuse')).

rule(75,diagnosis,cmc_joint_athritis,500):-
        check(symptoms,1,[pain, bump]),
        check(affected_fingers,1,[1]),
		(check(location,=,cmc);check(specific_locations,1,[cmc])).		

% rules for Collateral ligament Injury RCL
rule(80,diagnosis,collateral_ligament_injury_RCL,1000):-
        check(symptoms,3,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
		check(condition,1,['When moving finger']),
		check(condition_moving,3,[grabbing,twisting,turning,'Key Grip',pinch]),
	    (check(angle_test_radial,=,'More than 45 degrees');check(angle_test_radial,=,'More than 60 degrees')).

rule(81,diagnosis,collateral_ligament_injury_RCL,800):-
        check(symptoms,2,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch]),
	    (check(angle_test_radial,=,'More than 45 degrees');check(angle_test_radial,=,'More than 60 degrees')).
		
rule(82,diagnosis,collateral_ligament_injury_RCL,700):-
        check(symptoms,2,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch]),
	    (check(angle_test_radial,=,'More than 45 degrees');check(angle_test_radial,=,'More than 60 degrees')).

rule(83,diagnosis,collateral_ligament_injury_RCL,600):-
        check(symptoms,2,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch]).
		
rule(84,diagnosis,collateral_ligament_injury_RCL,500):-
        check(symptoms,3,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch]).
		
rule(85,diagnosis,collateral_ligament_injury_RCL,400):-
        check(symptoms,3,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
		check(condition,1,['When moving finger']),
		check(condition_moving,2,[grabbing,twisting,turning,'Key Grip',pinch]).
		
rule(86,diagnosis,collateral_ligament_injury_RCL,680):-
        check(symptoms,2,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		(check(location,=,mp);check(specific_locations,1,[mp])),
		check(cause,=,trauma),
		check(trauma_type,=,'Extreme inward bending of finger'),
	    (check(angle_test_radial,=,'More than 45 degrees');check(angle_test_radial,=,'More than 60 degrees')).
			
rule(87,diagnosis,collateral_ligament_injury_RCL,650):-
        check(symptoms,2,[pain, swelling, weakness]),
        check(affected_fingers,1,[1]),
		check(area,=,radial_side),
		(check(location,=,mp);check(specific_locations,1,[mp])).
		
% rules about what treatments the patient should get for very probable
%trigger finger treatments
rule(100,treatment,splint_on_mp_joint_overnight,1000):-
        check(diagnosis,trigger_finger,'cf>=',800),
		check(movement_test_1,=,'No pain or resistance').
		
rule(101,treatment,splint_on_ip_joint_during_day,1000):-
        check(diagnosis,trigger_finger,'cf>=',800),
		check(movement_test_1,=,'No pain or resistance').	

rule(102,treatment,'Exercise: Move thumb with other hand',1000):-
        check(diagnosis,trigger_finger,'cf>=',800),
		check(movement_test_1,=,'No pain or resistance').	
		
rule(103,treatment,'Allday Fixed splint in bended thumb position',1000):-
        check(diagnosis,trigger_finger,'cf>=',800),
		check(movement_test_1,=,'Still stuck').	

rule(104,treatment,'Exercise: Move thumb with other hand',1000):-
        check(diagnosis,trigger_finger,'cf>=',800),
		check(movement_test_1,=,'Still stuck').	
%less certain treatments
rule(1000,treatment,splint_on_mp_joint_overnight,600):-
        check(diagnosis,trigger_finger,'cf>=',600),
		check(movement_test_1,=,'No pain or resistance').
		
rule(1001,treatment,splint_on_ip_joint_during_day,600):-
        check(diagnosis,trigger_finger,'cf>=',600),
		check(movement_test_1,=,'No pain or resistance').	

rule(1002,treatment,'Exercise: Move thumb with other hand',600):-
        check(diagnosis,trigger_finger,'cf>=',600),
		check(movement_test_1,=,'No pain or resistance').	
		
rule(1003,treatment,'Allday Fixed splint in bended thumb position',600):-
        check(diagnosis,trigger_finger,'cf>=',600),
		check(movement_test_1,=,'Still stuck').	

rule(1004,treatment,'Exercise: Move thumb with other hand',600):-
        check(diagnosis,trigger_finger,'cf>=',600),
		check(movement_test_1,=,'Still stuck').			

%skiing thumb treatments
rule(110,treatment,'Put on splint for 4 weeks',1000):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		check(angle_test_ulnar,=,'More than 45 degrees'),
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high)),
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high)).
		
rule(111,treatment,'Put on splint for 4 weeks',900):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high)),
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high)).
		
rule(112,treatment,'Put on splint for 4 weeks',600):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		((check(angle_test_ulnar,=,'More than 45 degrees'));
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high));
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high))).			

rule(113,treatment,'Put on splint',1000):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).
		
rule(114,treatment,'Put on splint',900):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		(check(swelling_level,=,high);check(swelling_level,=,very_high)),
		(check(pain_level,=,high);check(pain_level,=,very_high)).
		
rule(115,treatment,'Put on splint',600):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).	
		
rule(116,treatment,'Send Patient to emergency',1000):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		check(angle_test_ulnar,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).	

rule(117,treatment,'Send Patient to emergency',900):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		(check(swelling_level,=,high);check(swelling_level,=,very_high)),
		(check(pain_level,=,high);check(pain_level,=,very_high)).

rule(118,treatment,'Send Patient to emergency',600):-
        check(diagnosis,skiing_thumb,'cf>=',800),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).

%less certain skiing thumb treatments
rule(1110,treatment,'Put on splint for 4 weeks',600):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		check(angle_test_ulnar,=,'More than 45 degrees'),
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high)),
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high)).
		
rule(1111,treatment,'Put on splint for 4 weeks',500):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high)),
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high)).
		
rule(1112,treatment,'Put on splint for 4 weeks',600):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		((check(angle_test_ulnar,=,'More than 45 degrees'));
		(check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high));
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high))).			

rule(1113,treatment,'Put on splint',600):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).
		
rule(1114,treatment,'Put on splint',500):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		(check(swelling_level,=,high);check(swelling_level,=,very_high)),
		(check(pain_level,=,high);check(pain_level,=,very_high)).
		
rule(1115,treatment,'Put on splint',400):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).	
		
rule(1116,treatment,'Send Patient to emergency',600):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		check(angle_test_ulnar,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).	

rule(1117,treatment,'Send Patient to emergency',500):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		(check(swelling_level,=,high);check(swelling_level,=,very_high)),
		(check(pain_level,=,high);check(pain_level,=,very_high)).

rule(1118,treatment,'Send Patient to emergency',400):-
        check(diagnosis,skiing_thumb,'cf>=',600),
		((check(angle_test_ulnar,=,'More than 60 degrees'));
		(check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).		


%De quervain treatments
rule(120,treatment,'Hard splint to wrist and MP joint',1000):-
        check(diagnosis,de_Quervain,'cf>=',800).	

rule(121,treatment,'Exercise: Move thumb with other hand',1000):-
        check(diagnosis,de_Quervain,'cf>=',800).	
		
rule(122,treatment,'Schedule meeting in 3 weeks',1000):-
        check(diagnosis,de_Quervain,'cf>=',800).	
		
%less certain De quervain treatments
rule(1200,treatment,'Hard splint to wrist and MP joint',600):-
        check(diagnosis,de_Quervain,'cf>=',600).	

rule(1201,treatment,'Exercise: Move thumb with other hand',600):-
        check(diagnosis,de_Quervain,'cf>=',600).	
		
rule(1202,treatment,'Schedule meeting in 3 weeks',600):-
        check(diagnosis,de_Quervain,'cf>=',600).			

%Mallet Finger treatments
rule(130,treatment,'Hard splint over IP Joint for 8 weeks',1000):-
        check(diagnosis,mallet_finger,'cf>=',800).	

% less certain Mallet Finger treatments
rule(1300,treatment,'Hard splint over IP Joint for 8 weeks',600):-
        check(diagnosis,mallet_finger,'cf>=',600).			


%Carpel Tunnel treatments
rule(140,treatment,'Nightly Prefabricated support: Splint inside wrist',1000):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',800).	

		
rule(141,treatment,'Schedule meeting in 4 weeks',1000):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',800).	
		
rule(142,treatment,'Exercise: Move thumb and wrist with other hand',1000):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',800).		

%Less certain Carpel Tunnel treatments
rule(1400,treatment,'Nightly Prefabricated support: Splint inside wrist',600):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',600).	

		
rule(1401,treatment,'Schedule meeting in 4 weeks',600):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',600).	
		
rule(1402,treatment,'Exercise: Move thumb and wrist with other hand',600):-
        check(diagnosis,carpal_tunnel_syndrome,'cf>=',600).				

%MP Joint Athritis treatments
rule(150,treatment,'Give Ergonomic advice',1000):-
        check(diagnosis,mp_joint_athritis,'cf>=',800).	

		
rule(151,treatment,'Exercise: Move thumb with other hand',1000):-
        check(diagnosis,mp_joint_athritis,'cf>=',800).	

%Less certain MP Joint Athritis treatments
rule(1500,treatment,'Give Ergonomic advice',600):-
        check(diagnosis,mp_joint_athritis,'cf>=',600).	

		
rule(1501,treatment,'Exercise: Move thumb with other hand',600):-
        check(diagnosis,mp_joint_athritis,'cf>=',600).		
		
%CMC Joint Athritis treatments
rule(160,treatment,'Day time support for thumb',1000):-
        check(diagnosis,cmc_joint_athritis,'cf>=',800),
		check(movement_test_3,=,'Yes').	

rule(161,treatment,'Day time and night-time support for thumb',1000):-
        check(diagnosis,cmc_joint_athritis,'cf>=',800),
		check(movement_test_3,=,'No').	

%CMC Joint Athritis treatments
rule(1600,treatment,'Day time support for thumb',600):-
        check(diagnosis,cmc_joint_athritis,'cf>=',600),
		check(movement_test_3,=,'Yes').	

rule(1601,treatment,'Day time and night-time support for thumb',600):-
        check(diagnosis,cmc_joint_athritis,'cf>=',600),
		check(movement_test_3,=,'No').	
		
			
%Radial collateral Ligament Treatment
rule(170,treatment,'Put on splint for 4 weeks',1000):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',800),
		check(angle_test_radial,=,'More than 45 degrees'),
		((check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high));
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high))).	

rule(171,treatment,'Put on splint',1000):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',800),
		check(angle_test_radial,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).
		
rule(172,treatment,'Send Patient to emergency',1000):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',800),
		check(angle_test_radial,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).		
			
%Less certain Radial collateral Ligament Treatment
rule(1700,treatment,'Put on splint for 4 weeks',600):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',600),
		check(angle_test_radial,=,'More than 45 degrees'),
		((check(swelling_level,=,low);check(swelling_level,=,medium);check(swelling_level,=,high));
		(check(pain_level,=,low);check(pain_level,=,medium);check(pain_level,=,high))).	

rule(1701,treatment,'Put on splint',600):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',600),
		check(angle_test_radial,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).
		
rule(1702,treatment,'Send Patient to emergency',600):-
        check(diagnosis,collateral_ligament_injury_RCL,'cf>=',600),
		check(angle_test_radial,=,'More than 60 degrees'),
		((check(swelling_level,=,high);check(swelling_level,=,very_high));
		(check(pain_level,=,high);check(pain_level,=,very_high))).
		
rule(1703,treatment,'Put hand in splint and consult with expert',600):-
        check(diagnosis,Any,'cf<=',500).		

% diagnos scharlakansfeber

%*****************************************************************        
%*****************************************************************        
% Window 6 - Presentation to the user


% *********************************************
% ************* Presentation of results *******
                
% Displays the conclusions and a menu with options to save answers, get
% how-explaniation or new consultation etc.

presentation_result:-
		\+tcl_GUI(on),
        to_present(Presentationsparametrar),nl,nl,
  write('Result:'), nl,
        ((result_exists(Presentationsparametrar),
        presentation(Presentationsparametrar)) ;
        write_no_result).

presentation_result:-
		tcl_GUI(on),
        to_present(Presentationsparametrar),
        present_setup(Presentationsparametrar).

present_setup(Presentationsparametrar):-		
		tcl_GUI(on),
		result_exists(Presentationsparametrar),!,
		assert_num_options(Presentationsparametrar),
        presentation(Presentationsparametrar),
		Source = 'source k:/kl�ver/conclusion.tcl',
		run_tcl(Source,Event),
		retract_and_destroy(Event).
present_setup(Presentationsparametrar):-
		tcl_GUI(on),
		\+result_exists(Presentationsparametrar),
		write_no_result.

result_exists(Presentationsparametrar):-
        setof(Object, (trigged(Object,_,CF), CF =\= 0,
              memb(Object,Presentationsparametrar)), Pres_List).

write_no_result:-
		\+tcl_GUI(on),
        write(' No conclusions have been drawn '), nl.
		
write_no_result:-
		tcl_GUI(on),
		Source = 'source k:/kl�ver/no_conclusion.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event).

% Finds all conclusions that have been allocated a value.
presentation([]).
presentation([Object | Rest]) :-
		\+tcl_GUI(on),
        findall((Attribute,CF) , (trigged(Object, Attribute, CF), CF =\= 0), Resultlist),
        write_result(Object,Resultlist),
        presentation(Rest).
%Finds and assert all conclusions that has a value
presentation([Object | Rest]) :-
		tcl_GUI(on),
		assert(answer_options(Object)), 
        findall((Attribute,CF) , (trigged(Object, Attribute, CF), CF =\= 0), Resultlist),
		%remove redundant conclusions
		member_check(Resultlist, NewList),
        assert_attr_list(Object, NewList),
		assert_num_attributes(Object, NewList),
        presentation(Rest).
	
member_check([],[]).
member_check([E|Rest],[E|New]):-
		\+member(E,Rest),
		member_check(Rest,New).
member_check([E|Rest],New):-
		member(E,Rest),
		member_check(Rest,New).		
	
%member(E,[E|Rest]):-
%	member(E,Rest).
%member(E,[F|Rest]):-
%	E \= F,
%	member(E,Rest).
	
% Prints all conclusions saved in the knowledge base
% that are connected to the conclusion. Presented as text strings.
write_result(Object, []).
write_result(Object, Resultlist) :-
        text(Object,String),
        write(String),nl,
        write_attr_list(Resultlist), nl.

% Prints all conclusions set to 'true' which means  
% they have propability > 100
write_attr_list([]).
write_attr_list([(Attribute, Value)|Rest]):-
		evaluation(Value,Text),
        write(Attribute),
        write('     - evaluated as '),
        write(Text),nl,
        write_attr_list(Rest).

		
		
% Translates certainty factors to text.
evaluation(Value,'very probable'):-
        Value >= 800,!.
evaluation(Value,'probable'):-
        Value >= 600, !.
evaluation(Value,'possible'):-
        Value >= 400, !.
evaluation(Value,'slight possibility'):-
        Value >= 200, !.
evaluation(Value,'can not be excluded'):-
        Value >= 0,!.
evaluation(Value,'probably not'):-
        Value >= -500,!.
evaluation(Value,'definitely not').




% Annes code for dam construction work.
arrange_write_list([]).
arrange_write_list(Stringlista):-
        Stringlista = [List1,List2|Rest],
        write_list(List1),
        write_list(List2),
        arrange_write_list(Rest).
% Annes code.
arrange_write_list(Stringlista):-
        Stringlista = [List1|Rest],
        write_list(List1),
        arrange_write_list(Rest).

write_list([]).
write_list([First|Rest]):-
        write(First), write(' '),
        write_list(Rest).


store_answers:-
        new(Fil, Volym, 'On what file?'),
        create(Fil, Volym, 'TEXT'),
        open(Fil, Volym),
        tell(Fil),
        listing(answer),
        nl(Fil),
        told,
        close(Fil).

%*****************************************************************        
%*****************************************************************        
% Window 7 - Text base

% Text used at presentation of results.

% text/2.
text(diagnosis,'The following is the Patient diagnosis').
text(treatment,'These are the suggested treatments for the patient').


%text(diagnos,'F�ljande diagnos st�lls ').



%*****************************************************************
%*****************************************************************
% Window 8 - Text base

not_check(Question,Condition,Answer):-
        check(Question,Condition,Answer),!,fail.


not_check(Object,Condition,Answer).

not_check(Object,Subject,CF,Amount):-
        check(Object,Subject,CF,Amount),
        !, fail.

not_check(Object,Subject,CF,Amount).


%*****************************************************************
%*****************************************************************
% Window 9 - Explanations

% ************ Why ? *****************
%Gives a text based explanation to why a certain question has been asked.

why_explanation(Object):-
        definition(Object,Text),!,
        write('Why explanation '),
        write(Object),nl,
        write(Text),nl.
why_explanation(Object):-
        write('No definition is given'),nl.


% *************  How ?  ******************

% Answers how-questions.
answer_howquestion:-
		\+tcl_GUI(on),
        read_which_how(Hur_object),
        collect_howansers(Hur_object,Hur_regler),
        present_how( Hur_regler).
answer_howquestion:-
		tcl_GUI(on),
        read_which_how(Hur_object), 
        collect_howansers(Hur_object,Hur_regler),
        present_how( Hur_regler).
		
% Asks what conclusion to be explained.
read_which_how(How_object):-
        findall(Object, rule_info(Object, Regellista), List),
        find_fired_objects(List, List_of_answers),
        arrange_how_list(List_of_answers, How_object).

arrange_how_list([Object], Object):-
		\+tcl_GUI(on),
        write('This conclusion exist:'),nl,
        menue_write([Object]).

arrange_how_list(List_of_answers, How_object):-
        \+tcl_GUI(on),
		write('These conclusions exists: '),nl,
        menue_write(List_of_answers),
        make_type_control(How_object).

%assert each conclusion and run a tcl window where user can pick a conclusion.
arrange_how_list(List_of_answers, How_object):-
        tcl_GUI(on),
		assert_each_option(List_of_answers),
		assert_num_options(List_of_answers),
		Source = 'source k:/kl�ver/pick_how.tcl',
		run_tcl(Source, Event),
		retract_and_destroy(Event),
		(
		Event = '', 		%if no conclusion was chosen
		How_object = 'no_valid_tcl_answer';	
		string_to_integer(Event, Int),
		get_single_answer(Int, List_of_answers,How_object)).
        		
make_type_control(Answer):-
        write('Which conclusion are you interested in? '),nl,
        read(Answer).

% Creates a list of all conclusions that have the value <> rejected.
find_fired_objects([],[]).
find_fired_objects([Object | List],[Object | List_of_answers]):-
        trigged(Object, Attribute, CF),
        CF =\= 0, !,
        find_fired_objects(List,List_of_answers).
find_fired_objects([Object | List],List_of_answers):-
        find_fired_objects(List,List_of_answers).

% Finds all rules used for an object and returns
% a list of rule numbers.
collect_howansers(How_object,Hur_regler):-
findall(Regelnr, (how(Regelnr,How_object,_,CF),CF \== rejected),Hur_regler).

% Prints out all rules that have put a value on how-object asked for.
present_how( []).
present_how( [Nr | Rest]):-
		nl,
        clause(rule(Nr,Object,Attribute,CF),Premise),
        how(Nr,Object,Attribute,CF2),
        CF2 \== rejected,
        write(rule(Nr,Object,Attribute,CF2)),
        write(' is true because: '), nl,
        create_prem_list(Premise, Premisslista),
        write_howpremises(Premisslista),nl,nl,
        present_how(Rest).

% Puts the premises in a rule as elements in a list.
% create_prem_list(+ premises from clause, - list of premises)
% For premises that are not compound (not in  parenthesis)
% No more premises.
create_prem_list(true, []).
% The first premis is followed by "and".
create_prem_list((A,B), [(A,and)|Rest]):-
        \+ connected(A),
        create_prem_list(B, Rest).
% The first premis is followed by an "or".
create_prem_list((A;B), [(A,or)|Rest]):-
        \+ connected(A),
        create_prem_list(B, Rest).
% Last premis.
create_prem_list(A, [(A, ' ')]):-
        \+ connected(A).
% If the premis is a compound it should be remade in the same manner.
% The first premis is followed by "and".
create_prem_list((A,B), [(A_List,and)|Rest]):-
        connected(A),
        create_prem_list(A, A_List),
        create_prem_list(B, Rest).
% The first premis is followed by an  "or".
create_prem_list((A;B),[(A_List, or)|Rest]):-
        connected(A),
        create_prem_list(A, A_List),
        create_prem_list(B, Rest).
% Last premis.
create_prem_list(A, [(A_List, ' ')]):-
        connected(A),
        create_prem_list(A, A_List).

%The premis is a nestled condition.
connected((A, B)).
connected((A; B)).


% Writes the premises to how and if they are given by the user or deduced.
write_howpremises([]).
write_howpremises([(Premise, Konnektor)| Rest]):-
		check_prem_type(Premise, Type),
        write_how_prem(Premise, Type), write(Konnektor), nl,
        write_howpremises(Rest).
		
/*
%Prints out a negated premis - r not implemented n.

write_how_prem(not Premise, no):-
        check_prem_type(Premise, Type),
        write_how_prem(Premise, Type),
        write('is not true').
*/
% Prints out a nestled (nastlad) premise.
write_how_prem(Premise, nested):-
		nl,
        write_howpremises(Premise).
% Prints out remaining premises.
write_how_prem(Premise, Type):-
        write(Premise), write(' is '), write(Type), write(' ').

% Checks the type a premis posesses.
check_prem_type(check(Object, Attribute, Condition, Value), concluded):-
        trigged(Object, _, _).
check_prem_type(not_check(Object, Attribute, Condition, Value), concluded).
check_prem_type(check(Object, Attribute, Truth_value), concluded):-
        (Truth_value = sant ; Truth_value = falskt),
        trigged(Object, _, _).
check_prem_type(check(Object, Condition, Attribute), 'given from the user'):-
        answer(Object, _).
check_prem_type(check(Object, Condition, Attribute), 'not answered'):-
        question_info(Object, Question, Alternativ, Type, Fragevillkor),
        \+ answer(Object, _).
%check_prem_type(not Premise, icke).
check_prem_type(Nested_premise, nested) :-
        list(Nested_premise).
check_prem_type(Premise, 'special conditions').

% Tests if the object is a list.
list([ ]).
list([A|B]). 



%*******************************************************************
%*******************************************************************
% Window 10 - Verification debugger tool

go_verify(Var):-
	var(Var),!,
	\+tcl_GUI(on),
    write('That option does not exist, please try again.'), nl,
	run_option('Verify rules').
	
%*************  Option 'Completeness' - rules not used and missing rules  ************
 
% 1. Unreachable rules: Checks that all rules (rule numbers) exists in specific clause of rule_info/2. 
% 2. Missing rules: Checks that all rule_info numbers got a connected rule (rule number).

go_verify('Completeness'):-
	newlines(20),
	non_reachable_rules,	%1. above
	missing_rules,			%2. above
	run_option('Verify rules').
	
missing_rules:-
		bagof(all(Object,Rules),rule_info(Object,Rules),RuleInfo_List),!, 
		nl,
		write('MISSING RULES'),nl,
		write('Check: if all numbers in rule_info/2 are represented as rule numbers in the rule base:'),nl,
		check_rule_no(RuleInfo_List),
		retractall(missing_rules(_,_)),
		write('**************************************'),nl.
	
missing_rules:-
		\+bagof(all(Object,Rules),rule_info(Object,Rules),RuleInfo_List),!, 
		write('rule_info/2 predicate are missing or is syntactically incorrect!'),nl,
		write('*************************************'),nl.
		%write('No rules can be reached'),nl.

%missing rule check		
% checks each rule_info(Object, List_of_numbers) if numbers have corresponding rules.		
	check_rule_no([]):- nl.
	
	check_rule_no([E|Rest]):-
		all(Object,Numbers) = E,
		check_no(Object,Numbers),
		output_missing_rule(Object),
		check_rule_no(Rest).

% check each number in rule_info/2 list if a corresponding rule exists (with that Oject and % Number), 
% if not - assert.
		check_no(_,[]).
		
		check_no(Object,[No|Rest]):-
			clause(rule(No,Object,_,_),_),
			check_no(Object,Rest).
		
		check_no(Object,[No|Rest]):-
			\+ clause(rule(No,Object,_,CF),_),
			assert(missing_rules(Object,No)),
			check_no(Object,Rest).

%**********************************************

non_reachable_rules:-
		findall((R_Num,Object),Y^Z^clause(rule(R_Num,Object,Y,Z), Body),Rule_Num), 
		Rule_Num \= [],
		nl,
		write('UNREACHABLE RULES'),nl,
		unique_check(Rule_Num),
		non_reachable_check(Rule_Num).
		
non_reachable_rules:-
		findall([R_Num,Object],Y^Z^clause(rule(R_Num,Object,Y,Z), Body),Rule_Num), 
		Rule_Num == [],
		write('No rules have been added to the rule base, or the format of the rules do not follow the format of rule/4'),nl,
		write('*************************************'),nl,nl.


%check if conclusion and rule numbers are unique, if not, 
%store and return specific rules in a list (unreachable check).	

	unique_check(Rule_Num):-
		unique(Rule_Num),
		write('Check 1: if all rules in the rule base have unique rule numbers'),nl,
		output_not_uniquenum,
		retractall(not_unique(_)),
		nl.
		
		unique([]).

		unique([Rule|Rest]):-
			members(Rule,Rest),!,
			assert(not_unique(Rule)),
			unique(Rest).

		unique([Rule|Rest]):-
			\+members(Rule,Rest),
			unique(Rest).	
	
	
%check of unreachable rules
	non_reachable_check(Rule_Num):-
		check_goal_conclusions,
		check_rinfo_no(Rule_Num),
		output_missingnum,
		output_missing_goal_conclusion,
		output_dead_end_goal,
		write('*************************************'),nl,nl.
	

		check_goal_conclusions:-
				findall(Object,List^rule_info(Object,List),Rule_infos), 
				Rule_infos \= [],
				check_goals(Rule_infos).
	
		check_goal_conclusions:-
				findall(Object,List^rule_info(Object,List),Rule_infos), 
				Rule_infos == [].
	
	
			check_goals([]).
			
			check_goals([Object|Rest]):-
				goal_conclusions(Goals),
				members(Object,Goals),
				check_goals(Rest).
				
			check_goals([Object|Rest]):-
				goal_conclusions(Goals),
				\+members(Object,Goals),
				assert(missing_goal(Object)),
				check_goals(Rest).
				
	
% check each rule if missing in rule_info/2	
		check_rinfo_no([]).

		check_rinfo_no([E|Rest]):-
			check_rule_info(E),!,
			check_rinfo_no(Rest).
		
		check_rinfo_no([(Num,Object)|Rest]):-
			assert(non_reached_rule(Num,Object)),
			check_rinfo_no(Rest).

% checks if a rule number is member of rule_info/2 		
			check_rule_info((Nr,Object)):-
				rule_info(Object,Numbers),
				members(Nr,Numbers).

%if rule_info/2 missing for object, then assert as a dead-end goal, and check as well if object is missing in goal_conclusions.	
			check_rule_info((Nr,Object)):-
				\+rule_info(Object,_),
				assert(no_goal(Object)),
				check_goals([Object]).


count_elems([],0):-!.

count_elems([H|T], Count):-
	count_elems(T, Sum),
	Count is Sum + 1.

members(Elem,[Elem|_]).

members(E,[F|Rest]):-
	\+ E = F,
	members(E,Rest).


%*****************************************************************************
%*************************  Redundancy check ***********************************		

go_verify('Redundancy'):-
	newlines(20),
	findall([rule(Num,Obj,Val,CF),Prem],clause(rule(Num,Obj,Val,CF),Prem),R_List),
	write('Redundant rules:'),nl,nl,
	redundant_check(R_List),
	run_option('Verify rules').

% redundant_check(List)
% List = all rules in rule base
% Goes through all rules and search for redundant rules in rest of the list
	redundant_check([]).

	redundant_check([[E,F|_]|Rest]):-
		count_premises(F,Number),
		check_redundancy(E,F,Number,Rest,New_Rest),
		output_redundancy(E,F),
		retractall(redundant_rule(_,_)),
		redundant_check(New_Rest).

%count_premises/2
% Counts number of premises for a rule,
% Example: Premises: (A,(B;C),D) equals 4.
% Main reason for this is to increase effectiveness of redundancy check
% - if two rules have different number of premises they can never be redundant!

		count_premises((P,P1),N):-
			count_premises(P,LP),
			count_premises(P1,LP1),
			!,
			N is LP + LP1.
		
		count_premises((P;P1),N):-
			count_premises(P,LP),
			count_premises(P1,LP1),
			!,
			N is LP + LP1.

%if current premise is instantiated (not end of premises) and not multiple premises then count 1.		
		count_premises(P,1):-
			\+ P = (_,_),
			\+ P = (_;_),
			ground(P),
			!.

% Base case: if current premise is uninstantiated (end of premises) then 0 and start backtracking.
		count_premises(P,0):-
			\+ P = (_,_),
			\+ P = (_;_),
			\+ ground(P),
			!.
		

% check_redundancy/5
% check_redundancy(Rule_N, Premises_N, Nr_of_premises_N, Rest_of_rules, New_Rest),
% compares one rule with all rules in Rest_of_rules.
% if redundant then remove rule from New_Rest -> efficiency and clean output.

			check_redundancy(_,_,_,[],[]).

%Add ruleT (rule + premises) to Answer if ruleN = ruleT AND nr_premises_N = nr_premises_T %AND premises_N redundant with premises_T.
%Does not add ruleT to Rest2.  		
			check_redundancy(rule(Nr,Obj,Val,CF),Clause,N1,[[E,F]|Rest],Rest2):-
				rule(_,Obj,Val,_)=E,
				count_premises(F,N2),
				N1 == N2,
				compare_clauses(Clause,F),
				assert(redundant_rule(E,F)),
				check_redundancy(rule(Nr,Obj,Val,CF),Clause,N1,Rest,Rest2).
		
			check_redundancy(rule(Nr,Obj,Val,CF),Clause,ClauseList,[[E,F]|Rest],[[E,F]|Rest2]):-
				check_redundancy(rule(Nr,Obj,Val,CF),Clause,ClauseList,Rest,Rest2).
		

% compare_clauses/2
% compare_clauses(Rule1_Premises, Rule2_Premises)
% Checks if premises of two rules are redundant, example: (A,(B;C);D) is redundant with (D;A,(B;C))
% compare_clauses/2 fails if premises are not redundant.

%called when last premise (P3) is multiple premises of structure: (A;B)
%Investigate first premise (P1), then rest of premises (P2) except last premise (P3)
%which is investigated last.
			compare_clauses(((P1);(P2,P3)), Body):-
				P3 = (A;B),!,
				find_structure_OR(((P1);(P2,P3)), Body,Body1,Body2),
				compare_clauses(P1, Body1),	
				compare_clauses(P2, Body2),
				find_structure_parenthes((A;B),Body2).

%if Body contains OR (;), check if P1 elements are members of either Body�s left side of OR %(;),
% or right side, do the same with P2.  
			compare_clauses(((P1);P2), Body):-
				find_structure_OR(((P1);P2),Body,Body1,Body2),
				compare_clauses(P1, Body1),
				compare_clauses(P2, Body2).	

%called when last premise (P3) is multiple premises of structure: (C;D)
% and current first premise (P1) is multiple premises (A;B)
%Investigate first premise (P1), then rest of premises (P2) except last premise (P3)
%which is investigated last. 
			compare_clauses((P1,(P2,P3)), Body):-
				P1 = (A;B),!,
				P3 = (C;D),!,
				find_structure_parenthes((A;B),Body),
				compare_clauses(P2, Body),
				find_structure_parenthes((C;D),Body).
		
%if P1 is a structure of premises in parentheses separated by or (;), then check if Body
% contain the same structure.
			compare_clauses((P1,P2), Body):-
				P1 = (A;B),!,
				find_structure_parenthes((A;B),Body),
				compare_clauses(P2, Body).

			compare_clauses((P1,(P2,P3)), Body):-
				P3 = (A;B),!,
				\+ P1 = (_,_),
				\+ P1 = (_;_),
					find_member(P1,Body), !,
				compare_clauses(P2, Body),
				find_structure_parenthes((A;B),Body).
		
%check if non-nested premise P1 is a member in Body		
			compare_clauses((P1,P2), Body):-
				\+ P1 = (_,_),
				\+ P1 = (_;_),
				find_member(P1,Body),
				compare_clauses(P2, Body).

%check if P (single premise) is member in Body
			compare_clauses(P, Body):-
				\+ P = (_,_),
				\+ P = (_;_),
				find_member(P, Body),!.
		
% if P is single premise and not member in body then compare_clauses fails 
% (rules are not redundant)
			compare_clauses(P, Body):-
				\+ P = (_,_),!,
				\+ P = (_;_),!,
				fail.


% find_structure_OR/4
% checks if structure (_;_) is member in premises of second rule 
% if member - return to compare_clauses left side premises of ; as Body1, return right side premises of ; as Body2,
% or if backtracking occurs - return left side of ; as Body2 and right side of ; as Body1
		
				find_structure_OR(((_);_), ((X);Y),X,Y).
				find_structure_OR(((_);_), (X;(Y)),Y,X).

% if current Body = (P1,P2) continue search for structure (_;_) in P2
				find_structure_OR(((_);_), (_,Y),_,_):-
					find_structure_OR(((_);_), Y,_,_).

% last single premise then fail (no premises connected by OR operator found)		
				find_structure_OR(((_);_), X,_,_):-
					\+ X = (_,_),
					\+ X = (_;_),
					fail,!.

% find_structure_parenthes/2
% search for structure ((_;_)) in Premises2.
% Example: Premises2 = (A,(B;C),D) -> structure ((_;_)) = ((P1;P2))
% if finding structure then continue search for P1 and P2 in this structure.
 
				find_structure_parenthes((P1;P2), (X,_)):-
					X = (_;_),!,
					find_structure_OR(((_);_), X,Body1,Body2),
					compare_clauses(P1, Body1),
					compare_clauses(P2, Body2).

				find_structure_parenthes((P1;P2), (X;_)):-
					X = (_;_),!,
					find_structure_OR(((_);_), X,Body1,Body2),
					compare_clauses(P1, Body1),
					compare_clauses(P2, Body2).

%structure not found in X then search Y				
				find_structure_parenthes((A;B), (X,Y)):-
					\+ X = (_;_),
					find_structure_parenthes((A;B), Y).

%structure not found in X then search Y
				find_structure_parenthes((A;B), (X;Y)):-
					\+ X = (_;_),
					find_structure_parenthes((A;B), Y).

%last single premise in Premise2 then fail. 		
				find_structure_parenthes((_;_), X):-
					\+ X = (_,_),
					\+ X = (_;_),
					fail,!.


% find_member/2
% no base case for scenario (P1, (P1;_)) because structure (_;_) is dealt with in find_structure2.
		
				find_member(P1, (P1,_)).

				find_member(P1,P1).

				find_member(P,(X,Y)):-
					\+ P = X,
					find_member(P,Y).

				find_member(P,(_;Y)):-
					find_member(P,Y).
						
				find_member(P,X):-
					\+ X = (_,_),
					\+ X = (_;_),
					\+ P = X,
					fail,!.
	
%***********************************************************
%*****************  Option 'Subsumed' - checks for subsumed rules  ***************

go_verify('Subsumption'):-
	newlines(20),
	findall([rule(Num,Obj,Val,CF),Prem],clause(rule(Num,Obj,Val,CF),Prem),R_List),
	nl,
	write('Subsumed rules:'),nl,nl,
	subsumed_check(R_List),
	run_option('Verify rules').


	subsumed_check([]).
	subsumed_check([[E,F]|Rest]):-
		count_premises(F,N1),
		check_subsumed(E,F,N1,Rest),
		output_subsumed,
		retractall(subsumed_rules(_,_,_,_)),
		subsumed_check(Rest).

		check_subsumed(_,_,_,[]).
		%when CF of both rules are positive		
		check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,[[rule(Nr2,Obj2,Val2,CF2),F]|Rest]):-
			rule(_,Obj,Val,_)= rule(_,Obj2,Val2,_),
			CF1 >= 0,
			CF2 >= 0,
			CF1 =< CF2,
			count_premises(F,N2),
			N1 > N2,
			compare_clauses(F,Clause),
			assert(subsumed_rules(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F)),
			%output_subsumed(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F),
			check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,Rest).

		%when CF of both rules are positive	
		check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,[[rule(Nr2,Obj2,Val2,CF2),F]|Rest]):-
			rule(_,Obj,Val,_)= rule(_,Obj2,Val2,_),
			CF1 >= 0,
			CF2 >= 0,
			CF1 >= CF2,
			count_premises(F,N2),
			N1 < N2,
			compare_clauses(Clause,F),
			assert(subsumed_rules(rule(Nr2,Obj2,Val2,CF2),F,rule(Nr,Obj,Val,CF1),Clause)),
			%output_subsumed(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F),
			check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,Rest).
	
		%when CF of both rules are negative
		check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,[[rule(Nr2,Obj2,Val2,CF2),F]|Rest]):-
			rule(_,Obj,Val,_)= rule(_,Obj2,Val2,_),
			CF1 < 0,
			CF2 < 0,
			CF1 >= CF2,
			count_premises(F,N2),
			N1 > N2,
			compare_clauses(F,Clause),
			assert(subsumed_rules(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F)),
			%output_subsumed(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F),
			check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,Rest).

		%when CF of both rules are negative	
		check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,[[rule(Nr2,Obj2,Val2,CF2),F]|Rest]):-
			rule(_,Obj,Val,_)= rule(_,Obj2,Val2,_),
			CF1 < 0,
			CF2 < 0,
			CF1 =< CF2,
			count_premises(F,N2),
			N1 < N2,
			compare_clauses(Clause,F),
			assert(subsumed_rules(rule(Nr2,Obj2,Val2,CF2),F,rule(Nr,Obj,Val,CF1),Clause)),
			%output_subsumed(rule(Nr,Obj,Val,CF1),Clause,rule(Nr2,Obj2,Val2,CF2),F),
			check_subsumed(rule(Nr,Obj,Val,CF1),Clause,N1,Rest).
		
		check_subsumed(rule(Nr,Obj,Val,CF),Clause,ClauseList,[[E,F]|Rest]):-
			check_subsumed(rule(Nr,Obj,Val,CF),Clause,ClauseList,Rest).

%********************************************************
%Help - explanation of automated verification tool

go_verify('Help'):-
	\+tcl_GUI(on),
	write('This is a beta version of an automated verification tool customized for the rule-based system shell Kl�ver.'),nl,
	write('The purpose of this tool is to help the rule-base developer test his/her rules for consistency and completeness.'),nl,
	write('It automatically detect and present errors and anomalies found in the rule-base.'),nl,nl,
	write('IMPORTANT! The verification tool does not alter the developers rule-base in any way!'),nl,nl,
	write('This verification tool is not fully implemented to check for all possible completeness and consistency errors.'),nl,nl,nl,
	go_help('Start'),
	run_option('Verify rules').
go_verify('Help'):-
	tcl_GUI(on),
	Source = 'source k:/kl�ver/v_help.tcl',
	run_tcl(Source, Event),
	retract_and_destroy(Event),
	go_help(Event).

%**********
%go_help/1
%**********
	
go_help(Var):-
	var(Var),!,
	go_help('invalid').
	
go_help('Start'):-
	write('************************************************'),nl,nl,
	write('HELP MENU'),nl,nl,
	write('The options below give you more information of the specific implemented error checkers:'),nl,nl,
	menue_write(['Redundancy','Subsumed','Completeness','Quit help']),
	read(Input),
	newlines(20),
	go_help(Input).
	

go_help('Redundancy'):-
	\+tcl_GUI(on),
	write('The "Redundancy" option detects:'),nl,nl,
	write('Syntactical redundant rules in the rule-base'),nl,
	write('   -Two syntactical redundant rules are two identical rules with identical premises and identical conclusions, belonging to the same rule class.'),nl,nl,nl,
	write('Options:'),nl,
	menue_write(['See example','Back']),
	read(Input),
	%newlines(20),
	go_more_info(Input,'Redundancy').
go_help('Redundancy'):-
	tcl_GUI(on),
	Source = 'source k:/kl�ver/r_help.tcl',
	run_tcl(Source, Event),
	retract_and_destroy(Event),
	go_help(Event).

go_help('Subsumed'):-
	\+tcl_GUI(on),
	write('Kl�ver is a rule-based system utilizing inexact reasoning by implementing Certainty Factors (CF).'),nl,
	write('When using Certainty Factors, two subsumed rules are two rules with identical conclusions in the same rule class, where the conditions of the'),nl, 
	write('first rule is a subset of the conditions of the second rule, and where the CF of the first rule is greater than than the CF of the second rule.'),nl,nl,
	write('Subsumed rules with CF can sometimes be utilized by purpose. However, according to the definition above, subsumed rules may be an indication of non-intended developer-induced errors, or misinterpretation of knowledge.'),nl,nl,	
	write('Options:'),nl,
	menue_write(['See example','Back']),
	read(Input),
	%newlines(20),
	go_more_info(Input,'Subsumed').
go_help('Subsumed'):-
	tcl_GUI(on),
	Source = 'source k:/kl�ver/s_help.tcl',
	run_tcl(Source, Event),
	retract_and_destroy(Event),
	go_help(Event).	
	
go_help('Completeness'):-
	\+tcl_GUI(on),
	write('The "Completeness" option detects:'),nl, 
	write('1. Unreachable rules.'),nl,
	write('2. Missing rules.'),nl,nl,
	write('The tool checks:'),nl,
	write('(1)if there exist rules with identical rule numbers and objects in the rule base.'),nl,
	write('(1)if there are rule numbers that does not exist in rule_info/2.'),nl,
	write('(1)if each object in the rule-base are represented in a clause of rule_info/2.'),nl,
	write('(1)if each object in the rule-base are represented in the list of goal_conclusions/1.'),nl,
	write('(2)if rule numbers present in rule_info/2 does not have a correspondent rule in the rule base.'),nl,nl,nl,  
	write('Options:'),nl,
	menue_write(['See example','Back']),
	read(Input),
	%newlines(20),
	go_more_info(Input,'Completeness').
go_help('Completeness'):-
	tcl_GUI(on),
	Source = 'source k:/kl�ver/c_help.tcl',
	run_tcl(Source, Event),
	retract_and_destroy(Event),
	go_help(Event).	
	
go_help('Back'):-
	\+tcl_GUI(on),
	newlines(20),
	go_help('Start').
go_help('Back'):-
	tcl_GUI(on),
	go_verify('Help').
	
go_help('Quit help'):-
	\+tcl_GUI(on),
	newlines(20).
go_help('Quit help'):-
	tcl_GUI(on),
	run_option('Verify rules').

go_help(Error):-
	\+tcl_GUI(on),
	write('That option does not exist.'),nl,nl,
	go_help('Start').

%**************
%go_more_info/2
%**************	

	go_more_info(Var,Option):-
		var(Var),!,
		write('That option does not exist.'),nl,nl,
		go_help(Option).
	
	go_more_info('See example','Redundancy'):-
		write('%rule(Rule_Number, Rule_Class, Rule_Attribute, Certainty_factor)'),nl,nl,
		write('Example of two syntactical redundant rules in Kl�ver:'),nl,nl,
		write('rule(1, Rule_Class2, Attribute1, 400):-'),nl,
		write('premise(A),'),nl,
		write('premise(B).'),nl,nl,
		write('redundant with:'),nl,nl,
		write('rule(2, Rule_Class2, Attribute1, 600):-'),nl,
		write('premise(B),'),nl,
		write('premise(A).'),nl,nl,nl,
		write('Options:'),nl,
		menue_write(['Back']),
		read(Input),
		newlines(20),
		go_more_info(Input,'Redundancy').
	
	go_more_info('See example','Subsumed'):-
		write('%rule(Rule_Number, Rule_Class, Rule_Attribute, Certainty_factor)'),nl,nl,
		write('Example of two subsumed rules in Kl�ver:'),nl,nl,
		write('rule(1, Rule_Class1, Attribute1, 400):-'),nl,
		write('premise(B),'),nl,
		write('premise(A).'),nl,nl,
		write('subsumed by:'),nl,nl,
		write('rule(2, Rule_Class1, Attribute1, 600):-'),nl,
		write('premise(A).'),nl,nl,nl,
		write('Options:'),nl,
		menue_write(['Back']),
		read(Input),
		newlines(20),
		go_more_info(Input,'Subsumed').
	
	go_more_info('See example','Completeness'):-
		write('%rule(Rule_Number, Object1, Attribute, Certainty_factor)'),nl,nl,
		write('Example of two rules with duplicated rule numbers and conclusions in Kl�ver:'),nl,nl,
		write('rule(10, Object1, Attribute1, 400):-'),nl,
		write('premise(A),'),nl,
		write('premise(B).'),nl,nl,
		write('has the same rule number and object as:'),nl,nl,
		write('rule(10, Object1, Attribute2, 600):-'),nl,
		write('premise(C).'),nl,nl,
		write('The second rule will never be reached when the first rule succeeds.'),nl,nl,
		write('*****************************************************'),nl,nl,
		write('Example of an unreachable rule in Kl�ver:'),nl,nl,
		write('rule_info(Object1,[1,3,4,5,6,7,8,9]).'),nl,nl,
		write('rule(2,Object1, Attribute1,600):-'),nl,
		write('premise(A).'),nl,nl,
		write('The rule number 2 is not represented in the clause of rule_info/2.'),nl,nl,
		write('***************************************************************'),nl,nl,
		write('Example of a missing clause of rule_info/2 in Kl�ver:'),nl,nl,
		write('rule_info(Object2,[3]).'),nl,nl,
		write('rule(1,Object1, Attribute1,600):-'),nl,
		write('premise(A).'),nl,nl,
		write('rule(3,Object2, Attribute1,200):-'),nl,
		write('premise(B).'),nl,
		write('.......................................'),nl,nl,
		write('A clause of rule_info/2 for Object1 is missing.'),nl,nl,
		write('***************************************************************'),nl,nl,
		write('Example of a missing object in goal_conclusions/1 in Kl�ver:'),nl,nl,
		write('goal_conclusions([Object1])'),nl,nl,
		write('rule(1,Object1, Attribute1,600):-'),nl,
		write('premise(A).'),nl,nl,
		write('rule(3,Object2, Attribute1,200):-'),nl,
		write('premise(B).'),nl,nl,
		write('Object2 is missing in goal_conclusions/1.'),nl,nl,
		write('***************************************************************'),nl,nl,
		write('Example of a missing rule in Kl�ver:'),nl,nl,
		%write('(when a number in rule_info\2 does not have a correspondent rule in the rule base)'),nl,nl,
		write('rule_info(Rule_Class2,[10,20,30,]).'),nl,nl,
		write('%Rule base:'),nl,
		write('rule(10,Rule_Class2, Attribute1,600):-'),nl,
		write('premise(A).'),nl,nl,
		write('rule(30,Rule_Class2, Attribute1,600):-'),nl,
		write('premise(B).'),nl,nl,
		write('There is no rule in the rule base with the rule number 20.'),nl,nl,nl,
		write('Options:'),nl,
		menue_write(['Back']),
		read(Input),
		newlines(20),
		go_more_info(Input,'Completeness').
	
	go_more_info('Back',_):-
		newlines(20),
		go_help('Start').
		
	go_more_info(Error,Option):-
		write('That option does not exist.'),nl,nl,
		go_help(Option).
		


%*************************************************************
%Quit to main menu

go_verify('Back').
	
%*************************************************************
%Misspelled input

go_verify(Answer):-
		\+tcl_GUI(on),
        write('That option does not exist, please try again.'), nl,
		run_option('Verify rules').
		

%**************************************************************
%******************  Output debugger  ******************

newlines(0) :- !.
newlines(N) :-
    N > 0,
    nl,
    N1 is N - 1,
    newlines(N1).

%*****************************************************
%Output results for Completeness check:

% output_missing_rule/1
% Output of numbers and object in rule_info/2 that do not have a connected rule
output_missing_rule(Object):-
	\+missing_rules(Object,_),
	nl,
	write('No '),
	write(Object),
	write(' rules are missing in the rule base.'),nl,nl.
	
output_missing_rule(Object):-
	nl,
	write('The following '),
	write(Object),
	write(' rules are missing in the rule base:'),nl,
	\+output_missing_asserted(Object).
				

output_missing_asserted(Object):-
	missing_rules(Object,Number),
	write('rule '),
	write(Number), nl, fail.
	
%******************************
% Output rules that have the same rulenumber and conclusion. 		

output_not_uniquenum(_):-
	\+not_unique(_),!,
	nl,
	write('All rule numbers are unique.'),nl,nl,
	write('*************************************'),nl,nl.

output_not_uniquenum:-
	nl,
	write('Rule numbers must be unique.'), nl,nl,
	write('These rules have not unique rule numbers: '), nl,
	\+output_not_unique_asserted,
	nl,
	write('*************************************'),nl.

output_not_unique_asserted:-
	not_unique(Rule),
	write('rule '),
	write(Rule), nl, fail.
	
%*********************************
% Output rules which numbers does not exist in corresponding rule_info/2.

output_missingnum:-		
	bagof(Object,Rules^rule_info(Object,Rules),Objects),
	write('Check 2: if all rule numbers in the rule base are represented in rule_info/2'),nl,nl,
	write('Rule numbers missing in rule_info/2: '),nl,nl,
	output_each_rule_info(Objects),nl,
	retractall(non_reached_rule(_,_)).
	
output_missingnum:-
	\+bagof(Object,Rules^rule_info(Object,Rules),Objects),!,
	nl.
	
output_each_rule_info([]).
output_each_rule_info([Object|Rest]):-
	\+non_reached_rule(_,Object),!,
	write('rule_info('),
	write(Object),write(', '),
	write('No numbers missing.'),
	write(')'),nl,nl,
	output_each_rule_info(Rest).
	
output_each_rule_info([Object|Rest]):-
	write('rule_info('),
	write(Object),
	write(', ['),
	non_reached_rule(Number,Object), %get first asserted anomalie
	write(Number),
	retract(non_reached_rule(Number,Object)), %delete first asserted anomalie
	\+output_reachable_asserted(Object),	%output rest of asserted anomalies
	write('])'),nl,nl,
	output_each_rule_info(Rest).
	
output_reachable_asserted(Object):-
		non_reached_rule(Number,Object),
		write(','),write(Number), fail.

%********************************************		
% Output missing Objects in list of goal_conclusions/1:	
output_missing_goal_conclusion:-
	\+missing_goal(_),!.
	
output_missing_goal_conclusion:-
	setof(Object,missing_goal(Object),Missing_Goals),
	output_missing_goals(Missing_Goals),
	retractall(missing_goal(_)),nl.

output_missing_goals([]).
output_missing_goals([Object|Rest]):-
	write('Object: "'),
	write(Object),
	write('" is missing in list of goal_conclusions/1!'),nl,nl,
	output_missing_goals(Rest).

%************************************************
% Output missing clauses of rule_info/2:	
output_dead_end_goal:-
	\+no_goal(_),!.
	
output_dead_end_goal:-
	setof(Object,no_goal(Object),Dead_Ends),
	output_dead_ends(Dead_Ends),
	retractall(no_goal(_)).

output_dead_ends([]).
output_dead_ends([Object|Rest]):-
	write('clause: rule_info('),
	write(Object),
	write(',[Numbers'),
	write(']) does not exist!'),nl,nl,
	output_dead_ends(Rest).

%**************************************************	
%**************************************************
%Output results for Redundancy check:
	
% Output information about redundant rules
output_redundancy(_,_):-
	\+redundant_rule(_,_),!.
	
output_redundancy(E,F):-
	write(E),
	write(':-'),nl,
	write(F),nl,nl,
	\+output_redundant_asserted,
	nl,
	write('*************************************'),nl,nl.
	
output_redundant_asserted:-
		redundant_rule(Conclusion,Premises),
		write(Conclusion),
		write(':-'),nl,
		write(Premises),nl,nl, fail.
			
output_rule([]):-
	nl,
	write('*************************************'),nl,nl.
output_rule([E|Rest]):-
	output_each_rule(E),
	output_rule(Rest).
		
output_each_rule([E,F]):-
	write(E),
	write(':-'),nl,
	write(F),nl,nl.
		
output_each([]):- nl.
output_each([E|Rest]):-
	members(E,Rest),!,
	output_each(Rest).
output_each([E|Rest]):-
	write('rule '),
	write(E), nl,
	output_each(Rest).

%*********************************************
%*********************************************
%Output results for Subsumed check:

output_subsumed:-
	\+subsumed_rules(_,_,_,_).
	
output_subsumed:-
	\+output_subsumed_asserted.
	
output_subsumed_asserted:-
	subsumed_rules(Conclusion1,Prem1,Conclusion2,Prem2),
	write(Conclusion1),
	write(':-'),nl,
	write(Prem1),nl,nl,
	write('are subsumed by'),nl,nl,
	write(Conclusion2),
	write(':-'),nl,
	write(Prem2),nl,nl,
	write('***************************'),nl,nl,fail.
	
%*********************************************
%prints out elements in a list
test_print([]).
test_print([E|Rest]):-
	write(E), nl,
	test_print(Rest).
