%%%% Knowledge Representation %%%%
% Author: Rodrigo S. Cortez Madrigal

% Class Structure

class(top).
class(_, _, _, _, _).
%class(ClassName, ParentClass, PropertyList, RelationList, ObjectList).
%[id=>ObjectName, PropertyList, RelationList].

%% Prolog Built-in Predicates

% findall: Sirve para encontrar todas las soluciones de una consulta.
% member: Sirve para comprobar si un elemento pertenece a una lista.
% append: Sirve para concatenar listas.
% select: Sirve para eliminar un elemento de una lista.
% exclude: Sirve para eliminar elementos de una lista que cumplan una condición.

%% 0. Auxiliares

% A. Subclases de una clase
% Encontrar todas las subclases de una clase.

% Argumentos:
    %Class: La clase de la cual queremos encontrar las subclases.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %Subclasses: La lista resultante de todas las subclases de Class.

subclasses_of(Class, KnowledgeBase, Subclasses) :-
    findall(Subclass, (member(class(Subclass, Class, _, _, _), KnowledgeBase)), DirectSubclasses),
    findall(SubSubclass, (member(Subclass, DirectSubclasses), subclasses_of(Subclass, KnowledgeBase, SubSubclass)), NestedSubclasses),
    flatten([DirectSubclasses | NestedSubclasses], Subclasses).

% B. Clases padre de una subclase
% Encontrar todas las clases padre de una subclase de manera recursiva.

% Argumentos:
    %Subclass: La subclase de la cual queremos encontrar las clases padre.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %ParentClasses: La lista resultante de todas las clases padre de Subclass.

parentclasses_of(Subclass, KnowledgeBase, ParentClasses) :-
    findall(ParentClass, (member(class(Subclass, ParentClass, _, _, _), KnowledgeBase)), DirectParentClasses),
    findall(ParentParentClass, (member(ParentClass, DirectParentClasses), parentclasses_of(ParentClass, KnowledgeBase, ParentParentClass)), NestedParentClasses),
    flatten([DirectParentClasses | NestedParentClasses], ParentClasses).

% C. Objetos de una clase

% Argumentos:
    %Class: La clase de la cual queremos encontrar los objetos.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %Objects: La lista resultante de todos los objetos de Class.

objects_of_class(Class, KnowledgeBase, Objects) :-
    findall(Object, (member(class(Class, _, _, _, Objects), KnowledgeBase), member([id=>Object, _, _], Objects)), Objects).

%% 1. Predicados para Consultar

% A. Extensión de una clase

%La extensión de una clase (el conjunto de todos los objetos que pertenecen a la misma, ya 
%sea  porque  se  declaren  directamente  o  porque  están  en  la  cerradura  de  la  relación  de 
%herencia). Llevará por nombre: class_extension, y recibirá tres argumentos: (i) el nombre 
%de la clase de la que se busca su extensión, (ii) la base de conocimientos en cuestión, y (iii) 
%el resultado de la extensión en una lista.

% Predicado para obtener la extensión de una clase
class_extension(Class, KnowledgeBase, Extension) :-
    subclasses_of(Class, KnowledgeBase, Subclasses),
    flatten([Class | Subclasses], AllClasses),
    findall(Object, (member(ClassName, AllClasses), objects_of_class(ClassName, KnowledgeBase, ClassObjects), member(Object, ClassObjects)), Extension).

% B. Extensión de una propiedad (NO FUNCIONA)

%La  extensión  de  una  propiedad  (mostrar  todos  los  objetos  que  tienen  una  propiedad 
%específica ya sea por declaración directa o por herencia, incluyendo su respectivo valor).  
%Llevará  por  nombre:  property_extension,  y  recibirá  tres  argumentos:  (i)  el  nombre  de  la 
%propiedad de la que se busca su extensión, (ii) la base de conocimientos en cuestión, y (iii) 
%el resultado de la extensión en una lista. 
%Con output: [Objeto, Valor]. Ej. Extension_Property = [pedro:yes, arturo:no].

property_extension(Property, KnowledgeBase, Extension) :-
    findall(Object-Value, (
        member(class(_, _, _, _, Objects), KnowledgeBase),
        member([id=>Object, Properties, _], Objects),
        member(Property=>Value, Properties)
    ), Extension).

% C. Extensión de una relación (NO FUNCIONA)

%La extensión de una relación (mostrar todos los objetos que tienen una relación específica 
%ya  sea  por  declaración  directa  o  por  herencia,  incluyendo  todos  los  objetos  con  quién 
%están relacionados).  Llevará  por  nombre:  relation_extension,  y  recibirá  tres argumentos: 
%(i) el nombre de la relación de la que se busca su extensión, (ii) la base de conocimientos 
%en cuestión, y (iii) el resultado de la extensión en una lista.

% Argumentos:
    %Relation: La relación de la que se busca su extensión.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %Extension: La lista resultante de la extensión de la relación Relation.

relation_extension(Relation, KnowledgeBase, Extension) :-
    findall(Object-Target, (
        member(class(_, _, _, _, Objects), KnowledgeBase),
        member([id=>Object, _, Relations], Objects),
        member(Relation=>Target, Relations)
    ), Extension).

% D. Clases de un individuo
% El conjunto de todas las clases a las que pertenece un objeto.

% Argumentos:
    %Individual: El objeto del cual queremos encontrar las clases a las que pertenece.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %Classes: La lista resultante de todas las clases a las que pertenece Individual.

classes_of_individual(Individual, KnowledgeBase, Classes) :-
    findall(Class, (member(class(Class, _, _, _, Objects), KnowledgeBase), member([id=>Individual, _, _], Objects)), DirectClasses),
    %Encontrar las clases padre de las clases a las que pertenece Individual
    findall(ParentClass, (member(Class, DirectClasses), parentclasses_of(Class, KnowledgeBase, ParentClass)), ParentClasses),
    flatten([DirectClasses | ParentClasses], Classes).

%% 2. Predicados para añadir

% A. Añadir una clase

add_class(NewClass,Father,KnowledgeBase,NewKnowledgeBase) :-
    member(class(Father,_,_,_,_),KnowledgeBase),
    not(member(class(NewClass,_,_,_,_),KnowledgeBase)),
    append(KnowledgeBase,[class(NewClass,Father,[],[],[])],NewKnowledgeBase).

% B. Añadir un objeto

add_object(Object, Class, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, _, _, _, Objects), KnowledgeBase),
    not(member([id=>Object, _, _], Objects)),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, [[id=>Object, [], []] | Objects]), NewKnowledgeBase).

%% 3. Predicados para eliminar

% A. Eliminar una clase

delete_class(Class, KnowledgeBase, NewKnowledgeBase) :-
    exclude([class(Class, _, _, _, _)]>>true, KnowledgeBase, NewKnowledgeBase).

% B. Eliminar un objeto

delete_object(Object, Class, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([id=>Object, _, _], Objects, NewObjects),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

%% Main

main :-

    % Cargar modulo I/O
    consult('IO.pl'),
    % Cargar base de conocimiento
    open_kb('KB.txt', KnowledgeBase1),

    subclasses_of(animales, KnowledgeBase1, AnimalSubclasses),
    format('Subclases de animales: ~w~n', [AnimalSubclasses]),
    subclasses_of(plantas, KnowledgeBase1, PlantasSubclasses),
    format('Subclases de plantas: ~w~n', [PlantasSubclasses]),

    add_class(paphiopedilum, orchidaceae, KnowledgeBase1, Update1),
    add_object(rositafresita, rosas, Update1, Update2),
    save_kb('KB.txt', Update2),
    format('Clase paphiopedilum añadida~n'),



    open_kb('KB.txt', KnowledgeBase2),

    subclasses_of(orchidaceae, KnowledgeBase2, OrchidaceaeSubclasses),
    format('Subclases de orchidaceae: ~w~n', [OrchidaceaeSubclasses]),
    
    parentclasses_of(paphiopedilum, KnowledgeBase2, PaphiopedilumParentClasses),
    format('Clases padre de paphiopedilum: ~w~n', [PaphiopedilumParentClasses]),
    parentclasses_of(aves, KnowledgeBase2, AvesParentClasses),
    format('Clases padre de aves: ~w~n', [AvesParentClasses]),

    class_extension(animales, KnowledgeBase2, AnimalExtension),
    format('Extension de la clase animales: ~w~n', [AnimalExtension]),
    class_extension(plantas, KnowledgeBase2, BirdExtension),
    format('Extension de la clase plantas: ~w~n', [BirdExtension]),

    property_extension(nadan, KnowledgeBase2, Extension),
    format('Extension de la propiedad nadan: ~w~n', [Extension]),

    relation_extension(comen, KnowledgeBase2, Comen),
    format('Extension de la relación comen: ~w~n', [Comen]),

    classes_of_individual(pedro, KnowledgeBase2, PedroClasses),
    format('Clases de Pedro: ~w~n', [PedroClasses]),
    classes_of_individual(arturo, KnowledgeBase2, ArturoClasses),
    format('Clases de Arturo: ~w~n', [ArturoClasses]),
    classes_of_individual(perry, KnowledgeBase2, PerryClasses),
    format('Clases de Perry: ~w~n', [PerryClasses]),
    classes_of_individual(rositafresita, KnowledgeBase2, RositaClasses),
    format('Clases de Rosita Fresita: ~w~n', [RositaClasses]),

    delete_class(paphiopedilum, KnowledgeBase2, Update3),
    delete_object(rositafresita, rosas, Update3, Update4),
    save_kb('KB.txt', Update4),

    halt.