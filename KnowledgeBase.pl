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
    findall(Object:Value, (
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
    findall(Object->Relation->Target, (
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

%A. Clases u objetos cuyo nombre será add_class y add_object, respectivamente. 
%Ambos predicados recibirán cuatro argumentos: (i) el nombre de la clase u objeto a añadir, (ii) el 
%nombre de la clase madre, (iii) la base de conocimientos actual, y (iv) la nueva base de 
%conocimientos donde se refleja la adición.

% A1. Añadir una clase

add_class(NewClass,Father,KnowledgeBase,NewKnowledgeBase) :-
    member(class(Father,_,_,_,_),KnowledgeBase),
    not(member(class(NewClass,_,_,_,_),KnowledgeBase)),
    append(KnowledgeBase,[class(NewClass,Father,[],[],[])],NewKnowledgeBase).

% A2. Añadir un objeto

add_object(Object, Class, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, _, _, _, Objects), KnowledgeBase),
    not(member([id=>Object, _, _], Objects)),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, [[id=>Object, [], []] | Objects]), NewKnowledgeBase).

%B. Propiedades de clases u objetos cuyo nombre será add_class_property y 
%add_object_property

%Ambos predicados recibirán cinco argumentos: (i) 
%el nombre de la clase u objeto, (ii) el nombre de la propiedad a añadir, (iii) el valor de 
%dicha propiedad, (iv) la base de conocimientos actual, y (v) la nueva base de 
%conocimientos donde se refleja la adición. 

% B1. Añadir una propiedad a una clase add_object_property

add_class_property(Class, Property, Value, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    not(member(Property=>Value, Properties)),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, [[Property=>Value] | Properties], Relations, Objects), NewKnowledgeBase).

% B2. Añadir una propiedad a un objeto add_object_property

add_object_property(Object, Property, Value, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, _, _, _, Objects), KnowledgeBase),
    member([id=>Object, Properties, Relations], Objects),
    not(member(Property=>Value, Properties)),
    select([id=>Object, Properties, Relations], Objects, [id=>Object, [[Property=>Value] | Properties], Relations], NewObjects),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

% C. Relaciones de clases u objetos cuyo nombre será add_class_relation y add_object_relation.

%Ambos predicados recibirán cinco argumentos: (i) el nombre de la clase 
%u objeto, (ii) el nombre de la relación a añadir, (iii) la o las clases con quienes se guarda la 
%relación, si se trata de add_class_relation, y el o los objetos con quienes se guarda la 
%relación, si el predicado es add_object_relation , (iv) la base de conocimientos actual, y (v) 
%la nueva base de conocimientos donde se refleja la adición. 

% C1. Añadir una relación a una clase

add_class_relation(Class, Relation, Target, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    not(member(Relation=>Target, Relations)),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, [[Relation=>Target] | Relations], Objects), NewKnowledgeBase).

% C2. Añadir una relación a un objeto

add_object_relation(Object, Relation, Target, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    member([id=>Object, ObjProperties, ObjRelations], Objects),
    not(member(Relation=>Target, ObjRelations)),
    select([id=>Object, ObjProperties, ObjRelations], Objects, [id=>Object, ObjProperties, [Relation=>Target | ObjRelations]], NewObjects),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

%% 3. Predicados para eliminar

%A. Clases u objetos cuyo nombre será rm_class y rm_object, respectivamente. 

%Ambos predicados recibirán tres argumentos: (i) el nombre de la clase u objeto a eliminar, (ii) la 
%base de conocimientos actual, y (iii) la nueva base de conocimientos donde se refleja la 
%eliminación.

% A1. Eliminar una clase

delete_class(Class, KnowledgeBase, NewKnowledgeBase) :-
    exclude([class(Class, _, _, _, _)]>>true, KnowledgeBase, NewKnowledgeBase).

% A2. Eliminar un objeto

delete_object(Object, Class, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([id=>Object, _, _], Objects, NewObjects),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

% B. Propiedades específicas de clases u objetos cuyo nombre será rm_class_property y rm_object_property. 

%Ambos predicados recibirán cuatro argumentos: (i) 
%el nombre de la clase u objeto, (ii) el nombre de la propiedad a eliminar, (iii) la base de 
%conocimientos actual, y (iv) la nueva base de conocimientos donde se refleja la 
%eliminación.

% B1. Eliminar una propiedad de una clase

delete_class_property(Class, Property, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([Property=>_], Properties, NewProperties),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, NewProperties, Relations, Objects), NewKnowledgeBase).

% B2. Eliminar una propiedad de un objeto

delete_object_property(Object, Class, Property, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, _, _, _, Objects), KnowledgeBase),
    member([id=>Object, ObjProperties, ObjRelations], Objects),
    select([Property=>_], ObjProperties, NewProperties),
    select([id=>Object, ObjProperties, ObjRelations], Objects, [id=>Object, NewProperties, ObjRelations], NewObjects),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

% C. Relaciones específicas de clases u objetos cuyo nombre será rm_class_relation y rm_object_relation. 

%Ambos predicados recibirán cuatro argumentos: (i) 
%el nombre de la clase u objeto, (ii) el nombre de la relación a eliminar, (iii) la base de 
%conocimientos actual, y (iv) la nueva base de conocimientos donde se refleja la eliminación. 

% C1. Eliminar una relación de una clase

delete_class_relation(Class, Relation, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([Relation=>_], Relations, NewRelations),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, NewRelations, Objects), NewKnowledgeBase).

% C2. Eliminar una relación de un objeto

delete_object_relation(Object, Class, Relation, KnowledgeBase, NewKnowledgeBase) :-
    % Encontrar la clase que contiene el objeto
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    % Encontrar el objeto dentro de la lista de objetos de la clase
    member([id=>Object, ObjProperties, ObjRelations], Objects),
    % Eliminar la relación del objeto
    select(Relation=>_, ObjRelations, UpdatedRelations),
    % Actualizar la lista de objetos con las nuevas relaciones del objeto
    select([id=>Object, ObjProperties, ObjRelations], Objects, [id=>Object, ObjProperties, UpdatedRelations], NewObjects),
    % Actualizar la clase con la nueva lista de objetos
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, Relations, NewObjects), NewKnowledgeBase).

%% 4. Predicados para modificar

%A. Cambiar el nombre de una clase u objeto cuyo nombre será change_class_name y change_object_name, respectivamente.

%Ambos predicados recibirán cuatro argumentos: (i) 
%el nombre de la clase u objeto a modificar, (ii) el nuevo nombre para dicha clase u objeto, 
%(iii) la base de conocimientos actual, y (iv) la nueva base de conocimientos donde se 
%refleja la modificación.

% A1. Cambiar el nombre de una clase

change_class_name(OldName, NewName, KnowledgeBase, NewKnowledgeBase) :-
    select(class(OldName, Father, Properties, Relations, Objects), KnowledgeBase, class(NewName, Father, Properties, Relations, Objects), NewKnowledgeBase).

% A2. Cambiar el nombre de un objeto

change_object_name(OldName, NewName, KnowledgeBase, NewKnowledgeBase) :-
    member(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase),
    select([id=>OldName | RestProps], Objects, RestObjects),
    select(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase, class(ClassName, ParentClass, Properties, Relations, [[id=>NewName | RestProps] | RestObjects]), NewKnowledgeBase).

% B. El valor de una propiedad específica de una clase u objeto cuyo nombre será change_value_class_property y change_value_object_property, respectivamente.

%Ambos predicados recibirán cinco argumentos: (i) el nombre de la clase u objeto, (ii) el nombre 
%de la propiedad a modificar, (iii) el nuevo valor de dicha propiedad, (iv) la base de 
%conocimientos actual, y (v) la nueva base de conocimientos donde se refleja la 
%modificación.

% B1. Cambiar el valor de una propiedad de una clase

change_value_class_property(Class, Property, NewValue, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([Property=>_], Properties, NewProperties),
    append(NewProperties, [[Property=>NewValue]], UpdatedProperties),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, UpdatedProperties, Relations, Objects), NewKnowledgeBase).

% B2. Cambiar el valor de una propiedad de un objeto

change_value_object_property(Object, Property, NewValue, KnowledgeBase, NewKnowledgeBase) :-
    member(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase),
    member([id=>Object, ObjProperties, ObjRelations], Objects),
    select([Property=>_], ObjProperties, NewProperties),
    append(NewProperties, [[Property=>NewValue]], UpdatedProperties),
    select([id=>Object, ObjProperties, ObjRelations], Objects, [id=>Object, UpdatedProperties, ObjRelations], NewObjects),
    select(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase, class(ClassName, ParentClass, Properties, Relations, NewObjects), NewKnowledgeBase).
    
% C. Con quién mantiene una relación específica una clase u objeto cuyo nombre será change_value_class_relation y change_value_object_relation, respectivamente. 

%Ambos predicados recibirán cinco argumentos: (i) el nombre de la clase u objeto, (ii) el nombre 
%de la relación a modificar, (iii) la o las clases con quienes ahora se guarda la relación, si se 
%trata de change_value_class_relation, y el o los objetos con quienes ahora se guarda la 
%relación, si el predicado es change_value_object_relation, (iv) la base de conocimientos 
%actual, y (v) la nueva base de conocimientos donde se refleja la modificación.

% C1. Cambiar el valor de una relación de una clase

change_value_class_relation(Class, Relation, NewTarget, KnowledgeBase, NewKnowledgeBase) :-
    member(class(Class, Father, Properties, Relations, Objects), KnowledgeBase),
    select([Relation=>_], Relations, NewRelations),
    append(NewRelations, [[Relation=>NewTarget]], UpdatedRelations),
    select(class(Class, Father, Properties, Relations, Objects), KnowledgeBase, class(Class, Father, Properties, UpdatedRelations, Objects), NewKnowledgeBase).

% C2. Cambiar el valor de una relación de un objeto

change_value_object_relation(Object, Relation, NewTarget, KnowledgeBase, NewKnowledgeBase) :-
    % Encontrar la clase que contiene el objeto
    member(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase),
    % Encontrar el objeto dentro de la lista de objetos de la clase
    member([id=>Object, ObjProperties, ObjRelations], Objects),
    % Cambiar el valor de la relación
    select(Relation=>_, ObjRelations, TempRelations),
    append([Relation=>NewTarget], TempRelations, UpdatedRelations),
    % Actualizar la lista de objetos con las nuevas relaciones del objeto
    select([id=>Object, ObjProperties, ObjRelations], Objects, [id=>Object, ObjProperties, UpdatedRelations], NewObjects),
    % Actualizar la clase con la nueva lista de objetos
    select(class(ClassName, ParentClass, Properties, Relations, Objects), KnowledgeBase, class(ClassName, ParentClass, Properties, Relations, NewObjects), NewKnowledgeBase).

%% Main

main :-

    %% Inicialización %%

    % Cargar modulo I/O
    consult('IO.pl'),
    % Cargar base de conocimieento
    open_kb('KB.txt', KnowledgeBase1),

    %%% Pruebas añadir %%%

    write('Añadiendo...'), nl,

    add_class(paphiopedilum, orchidaceae, KnowledgeBase1, Update1),
    add_object(rosy, rosas, Update1, Update2),

    add_class_property(paphiopedilum, altura, '30cm', Update2, Update3),
    add_object_property(rosy, color, rojo, Update3, Update4),

    add_class_relation(ornitorrincos, comen, paphiopedilum, Update4, Update5),
    add_object_relation(perry, comen, rosy, Update5, Update6),

    %%% Pruebas modificar %%%

    write('Modificando...'), nl,

    change_class_name(paphiopedilum, paphiopedilumdelenatii, Update6, Update7),
    change_object_name(rosy, rositafresita, Update7, Update8),

    change_value_class_property(paphiopedilumdelenatii, altura, '22cm', Update8, Update9),
    change_value_object_property(rositafresita, color, rosa, Update9, Update10),

    change_value_class_relation(ornitorrincos, comen, paphiopedilumdelenatii, Update10, Update11),
    change_value_object_relation(perry, comen, rositafresita, Update11, Update12),

    %% Guardar base de conocimiento %%

    save_kb('KB.txt', Update12),
    open_kb('KB.txt', KnowledgeBase2),

    %% Pruebas de predicados %%

    write('Consultando...'), nl,

    subclasses_of(animales, KnowledgeBase1, AnimalSubclasses),
    format('Subclases de animales: ~w~n', [AnimalSubclasses]),
    subclasses_of(plantas, KnowledgeBase1, PlantasSubclasses),
    format('Subclases de plantas: ~w~n', [PlantasSubclasses]),

    subclasses_of(orchidaceae, KnowledgeBase2, OrchidaceaeSubclasses),
    format('Subclases de orchidaceae: ~w~n', [OrchidaceaeSubclasses]),
    
    parentclasses_of(paphiopedilumdelenatii, KnowledgeBase2, PaphiopedilumParentClasses),
    format('Clases padre de paphiopedilumdelenatii: ~w~n', [PaphiopedilumParentClasses]),
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

    %% Pruebas eliminar %%

    write('Eliminando...'), nl,

    delete_class_property(paphiopedilumdelenatii, altura, Update12, Update13),
    delete_object_property(rositafresita, rosas, color, Update13, Update14),

    delete_class_relation(ornitorrincos, comen, Update14, Update15),
    delete_object_relation(perry, ornitorrincos, comen, Update15, Update16),

    delete_class(paphiopedilumdelenatii, Update16, Update17),
    delete_object(rositafresita, rosas, Update17, Update18),

    save_kb('KB.txt', Update18),

    %% Fin %%

    halt.