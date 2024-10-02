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

%% 1. Predicados para Consultar

% A. Extensión de una clase
% El conjunto de todos los objetos que pertenecen a la misma, ya sea  porque  se  declaren  directamente o por herencia.

% B. Extensión de una propiedad
% El conjunto de todos los objetos que tienen una propiedad específica.

% C. Extensión de una relación
% Mostrar todos los objetos que tienen una relación específica ya  sea  por  declaración  directa  o  por  herencia,  incluyendo  todos  los  objetos  con  quién están relacionados

% D. Clases de un individuo
% El conjunto de todas las clases a las que pertenece un objeto.

%% Main

main :-
    KnowledgeBase = [
        class(top, none, [], [], []),
        class(animales, top, [], [], []),
        class(plantas, top, [], [], []),
        class(orquidae, plantas, [], [not(bailan), 0], []),
        class(rosas, plantas, [], [], [
            [id=>rosa, [[color=>rojo, 0]], []]
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
        class(ornitorrincos, mamiferos, [[oviparos, 0]], [], [])
    ],
    %class_extension(animales, KnowledgeBase, AnimalExtension),
    %format('Extension de la clase animales: ~w~n', [AnimalExtension]),
    %class_extension(plantas, KnowledgeBase, BirdExtension),
    %format('Extension de la clase plantas: ~w~n', [BirdExtension]),
    %classes_of_individual(pedro, KnowledgeBase, PedroClasses),
    %format('Clases de Pedro: ~w~n', [PedroClasses]),
    %classes_of_individual(arturo, KnowledgeBase, ArturoClasses),
    %format('Clases de Arturo: ~w~n', [ArturoClasses]),
    %property_extension(vuelan, KnowledgeBase, Flyers),
    %format('Extension de la propiedad vuelan: ~w~n', [Flyers]),
    %relation_extension(comen, KnowledgeBase, Comen),
    %format('Extension de la relación comen: ~w~n', [Comen]),
    halt.