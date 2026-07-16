% Simple Programming Language Recommendation System

:- dynamic goal/1, knows/1, prefers/1, os/1, mobile_target/1.


% ------------------------------------------------------------
% Start and reset
% ------------------------------------------------------------

start :-
    reset,
    header,
    ask_questions,
    show_recommendations.

reset :-
    retractall(goal(_)),
    retractall(knows(_)),
    retractall(prefers(_)),
    retractall(os(_)),
    retractall(mobile_target(_)).

header :-
    nl,
    writeln('=========================================='),
    writeln(' Programming Language Recommendation'),
    writeln('=========================================='),
    writeln('End each answer with a period. Example: 1.'),
    nl.


% ------------------------------------------------------------
% Questions
% ------------------------------------------------------------

ask_questions :-
    ask_goal,
    ask_languages,
    ask_yes_no('Do you prefer an easy language?', easy),
    ask_yes_no('Is high performance important?', performance),
    ask_yes_no('Do you prefer object-oriented programming?', oop),
    ask_yes_no('Do you prefer functional programming?', functional),
    ask_os,
    ask_mobile_target.

ask_goal :-
    writeln('What do you want to create?'),
    writeln('1. Web application'),
    writeln('2. Data science project'),
    writeln('3. Mobile application'),
    writeln('4. System software'),
    writeln('5. Video game'),
    ask_number('Choose 1 to 5: ', 1, 5, Choice),
    goal_choice(Choice, Goal),
    assertz(goal(Goal)).

goal_choice(1, web).
goal_choice(2, data_science).
goal_choice(3, mobile).
goal_choice(4, systems).
goal_choice(5, games).


% Ask which languages the user already knows.

ask_languages :-
    nl,
    writeln('Which languages do you already know?'),
    writeln('1. Python'),
    writeln('2. Java'),
    writeln('3. JavaScript'),
    writeln('4. C'),
    writeln('5. C++'),
    writeln('6. Ruby'),
    writeln('7. Swift'),
    writeln('8. Kotlin'),
    writeln('9. R'),
    writeln('10. MATLAB'),
    writeln('11. Haskell'),
    writeln('12. Elixir'),
    writeln('Enter 0 when finished.'),
    read_languages.

read_languages :-
    ask_number('Language number: ', 0, 12, Choice),
    ( Choice = 0 ->
        true
    ;
        language_choice(Choice, Language),
        add_language(Language),
        read_languages
    ).

language_choice(1, python).
language_choice(2, java).
language_choice(3, javascript).
language_choice(4, c).
language_choice(5, cpp).
language_choice(6, ruby).
language_choice(7, swift).
language_choice(8, kotlin).
language_choice(9, r).
language_choice(10, matlab).
language_choice(11, haskell).
language_choice(12, elixir).

add_language(Language) :-
    ( knows(Language) ->
        format('~w is already selected.~n', [Language])
    ;
        assertz(knows(Language)),
        format('Added ~w.~n', [Language])
    ).


% Ask for the users operating system.

ask_os :-
    nl,
    writeln('Which operating system do you use?'),
    writeln('1. Windows'),
    writeln('2. macOS'),
    writeln('3. Linux'),
    ask_number('Choose 1 to 3: ', 1, 3, Choice),
    os_choice(Choice, OS),
    assertz(os(OS)).

os_choice(1, windows).
os_choice(2, mac).
os_choice(3, linux).


% Ask for a mobile target only when the goal is mobile.

ask_mobile_target :-
    goal(mobile), !,
    nl,
    writeln('Which mobile platform do you want to target?'),
    writeln('1. Android'),
    writeln('2. iOS'),
    writeln('3. Cross-platform'),
    ask_number('Choose 1 to 3: ', 1, 3, Choice),
    mobile_choice(Choice, Target),
    assertz(mobile_target(Target)).

ask_mobile_target.

mobile_choice(1, android).
mobile_choice(2, ios).
mobile_choice(3, cross_platform).


% ------------------------------------------------------------
% Input helpers
% ------------------------------------------------------------

ask_number(Prompt, Min, Max, Number) :-
    write(Prompt),
    read(Input),
    ( integer(Input), Input >= Min, Input =< Max ->
        Number = Input
    ;
        format('Enter a number from ~w to ~w.~n', [Min, Max]),
        ask_number(Prompt, Min, Max, Number)
    ).

ask_yes_no(Question, Preference) :-
    format('~w (y/n): ', [Question]),
    read(Answer),
    ( Answer = y ->
        assertz(prefers(Preference))
    ; Answer = n ->
        true
    ;
        writeln('Please enter y. or n.'),
        ask_yes_no(Question, Preference)
    ).


% ------------------------------------------------------------
% Recommendation rules
% ------------------------------------------------------------

recommend(python) :-
    goal(data_science), easy_language.
recommend(r) :-
    goal(data_science), prefers(functional).
recommend(matlab) :-
    goal(data_science).

recommend(javascript) :-
    goal(web), easy_language.
recommend(ruby) :-
    goal(web), prefers(oop).
recommend(elixir) :-
    goal(web), prefers(functional).

recommend(kotlin) :-
    goal(mobile), mobile_target(android).
recommend(java) :-
    goal(mobile), mobile_target(android), prefers(oop).
recommend(swift) :-
    goal(mobile), mobile_target(ios).
recommend(javascript) :-
    goal(mobile), mobile_target(cross_platform).

recommend(c) :-
    goal(systems), prefers(performance).
recommend(cpp) :-
    goal(systems).
recommend(haskell) :-
    goal(systems), prefers(functional).

recommend(cpp) :-
    goal(games).


% The user likes easy languages when selected or already familiar.

easy_language :- prefers(easy).
easy_language :- knows(python).
easy_language :- knows(javascript).
easy_language :- knows(ruby).


% Do not recommend a language the user already knows.

new_language(Language) :-
    recommend(Language),
    \+ knows(Language).


% ------------------------------------------------------------
% Show recommendations
% ------------------------------------------------------------

show_recommendations :-
    findall(Language, new_language(Language), Results),
    sort(Results, Languages),
    nl,
    writeln('Recommended languages:'),
    writeln('----------------------'),
    show_result(Languages),
    ios_warning.

show_result([]) :-
    fallback(Language),
    format('No exact match. Try ~w as a starting point.~n', [Language]).

show_result(Languages) :-
    print_languages(Languages).

print_languages([]).
print_languages([Language | Rest]) :-
    description(Language, Text),
    format('* ~w: ~w~n', [Language, Text]),
    print_languages(Rest).


% Default recommendation for each goal.

fallback(javascript) :- goal(web).
fallback(python) :- goal(data_science).
fallback(kotlin) :-
    goal(mobile), mobile_target(android).
fallback(swift) :-
    goal(mobile), mobile_target(ios).
fallback(javascript) :-
    goal(mobile), mobile_target(cross_platform).
fallback(c) :- goal(systems).
fallback(cpp) :- goal(games).


% Warn users when iOS development is selected without macOS.

ios_warning :-
    goal(mobile),
    mobile_target(ios),
    \+ os(mac), !,
    nl,
    writeln('Note: Native iOS development requires macOS and Xcode.').

ios_warning.


% ------------------------------------------------------------
% Language descriptions
% ------------------------------------------------------------

description(python, 'Easy to learn and useful for data science.').
description(java, 'Used for object-oriented Android development.').
description(javascript, 'Popular for web and cross-platform apps.').
description(c, 'Fast and commonly used for system software.').
description(cpp, 'Used for high-performance systems and games.').
description(ruby, 'An expressive language for web development.').
description(swift, 'Apple''s language for iOS applications.').
description(kotlin, 'A modern language for Android applications.').
description(r, 'Used for statistics and data analysis.').
description(matlab, 'Used for numerical and engineering work.').
description(haskell, 'A strongly typed functional language.').
description(elixir, 'A functional language for scalable systems.').