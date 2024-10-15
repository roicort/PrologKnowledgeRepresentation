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
    findall(Object, (member(ClassName, AllClasses), member(class(ClassName, _, _, _, Objects), KnowledgeBase), member([id=>Object, _, _], Objects)), Extension).

% B. Extensión de una propiedad

%La  extensión  de  una  propiedad  (mostrar  todos  los  objetos  que  tienen  una  propiedad 
%específica ya sea por declaración directa o por herencia, incluyendo su respectivo valor).  
%Llevará  por  nombre:  property_extension,  y  recibirá  tres  argumentos:  (i)  el  nombre  de  la 
%propiedad de la que se busca su extensión, (ii) la base de conocimientos en cuestión, y (iii) 
%el resultado de la extensión en una lista. 
%Con output: [Objeto, Valor]. Ej. Extension_Property = [pedro:yes, arturo:no].

% C. Extensión de una relación
% Mostrar todos los objetos que tienen una relación específica ya  sea  por  declaración  directa  o  por  herencia,  incluyendo  todos  los  objetos  con  quién están relacionados

% Argumentos:
    %Relation: La relación de la que se busca su extensión.
    %KnowledgeBase: La base de conocimiento que contiene las definiciones de clases.
    %Extension: La lista resultante de la extensión de la relación Relation.

relation_extension(Relation, KnowledgeBase, Extension) :-

% D. Clases de un individuo
% El conjunto de todas las clases a las que pertenece un objeto.

%% Main

main :-
    KnowledgeBase = [
        class(top, none, [], [], []),
        class(animales, top, [], [], [
            [id=>eslabonperdido, [], []]
        ]),
        class(plantas, top, [], [], []),
        class(orquidae, plantas, [], [not(bailan), 0], []),
        class(rosas, plantas, [], [], [
            [id=>rositafresita, [[color=>rojo, 0]], []]
        ]),
        class(aves, animales, [[vuelan, 0], [not(nadan), 0]], [], []),  
        class(peces, animales, [[nadan, 0], [not(bailan), 0]], [],
            [
            [id=>nemo, [], []]
            ]), 
        class(mamiferos, animales, [[not(oviparos), 0]], [], []),
        class(aguilas, aves, [], [[comen=>peces, 0]],
            [
            [id=>pedro, [[tam=>grande, 0]], [[not(amigo=>arturo), 0]]]
            ]),
        class(pinguino, aves, [[not(vuelan), 0], [nadan, 0]], [],
            [
            [id=>arturo, [[listo, 0]], [[amigo=>pedro, 0]]]
            ]),
        class(ornitorrincos, mamiferos, [[oviparos, 0]], [], [
            [id=>perry, [[agente=>007, 0]], []]
        ])
    ],

    subclasses_of(animales, KnowledgeBase, AnimalSubclasses),
    format('Subclases de animales: ~w~n', [AnimalSubclasses]),
    subclasses_of(plantas, KnowledgeBase, PlantasSubclasses),
    format('Subclases de plantas: ~w~n', [PlantasSubclasses]),

    class_extension(animales, KnowledgeBase, AnimalExtension),
    format('Extension de la clase animales: ~w~n', [AnimalExtension]),
    class_extension(plantas, KnowledgeBase, BirdExtension),
    format('Extension de la clase plantas: ~w~n', [BirdExtension]),

    property_extension(nadan, KnowledgeBase, Extension),
    format('Extension de la propiedad nadan: ~w~n', [Extension]),

    %classes_of_individual(pedro, KnowledgeBase, PedroClasses),
    %format('Clases de Pedro: ~w~n', [PedroClasses]),
    %classes_of_individual(arturo, KnowledgeBase, ArturoClasses),
    %format('Clases de Arturo: ~w~n', [ArturoClasses]),
    %relation_extension(comen, KnowledgeBase, Comen),
    %format('Extension de la relación comen: ~w~n', [Comen]),
    halt.