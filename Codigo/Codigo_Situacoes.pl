%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Parte 1: Conhecimento estatico do dominio ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tamanho dos blocos (em número de slots ocupados)
tamanho(a,1).
tamanho(b,1).
tamanho(c,2).
tamanho(d,3).

% Slots da mesa (0..5)
table_slot(0). table_slot(1). table_slot(2). table_slot(3).
table_slot(4). table_slot(5).
table_width(6).

% Blocos do mundo
block(a). block(b). block(c). block(d).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Parte 2: Estado inicial (S0) ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

estado_inicial_s1([
    pos(c, table(0)),    % C ocupa slots 0 e 1
    pos(a, table(3)),    % A sobre C (offset 0)
    pos(b, table(5)),    % B sobre C (offset 1)
    pos(d, on(a, 0)),    % D ocupa slots 3, 4, 5
    clear(b),
    clear(d)
]).

estado_inicial_s2([
    pos(c, table(0)),    % C ocupa slots 0 e 1
    pos(d, table(3)),    % D ocupa slots 3, 4, 5
    pos(a, on(c, 0)),    % A sobre C (offset 0)
    pos(b, on(c, 1)),    % B sobre C (offset 1)
    clear(b),
    clear(d)
]).

estado_inicial_s3([
    pos(c, table(0)),    % C ocupa slots 0 e 1
    pos(a, table(3)),    % D ocupa slots 3, 4, 5
    pos(b, table(5)),    % A sobre C (offset 0)
    pos(d, on(a, 0)),    % B sobre C (offset 1)
    clear(b),
    clear(d)
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Parte 3: Estados Finais (S1, S2, S3) ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

estado_final_s1([
    pos(c, table(0)),    % B sobre C 
    pos(d, table(2)),    % B sobre C 
    pos(b, table(5)),    % B sobre C 
    pos(a, on(c, 0)),    % D ocupa slots 3, 4, 5
    clear(d),
    clear(a)
]).

estado_final_s2([
    pos(d, table(3)),
    pos(c, on(d, 1)),
    pos(a, on(c, 0)),
    pos(b, on(c, 1)),
    clear(a),
    clear(b)
]).

estado_final_s3([
    pos(c, table(0)),    % C ocupa slots 0 e 1
    pos(d, table(3)),    % D ocupa slots 3, 4, 5
    pos(a, on(c, 0)),    % A sobre C (offset 0)
    pos(b, on(c, 1)),    % B sobre C (offset 1)
    clear(b),
    clear(d)
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Impressão de Estados -------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imprimir_estado(Estado) :-
    write('=== ESTADO ==='), nl,
    imprimir_posicoes(Estado),
    desenhar_mesa_completa(Estado), nl.

imprimir_posicoes([]).
imprimir_posicoes([H|T]) :-
    imprimir_elemento(H),
    imprimir_posicoes(T).

imprimir_elemento(pos(Bloco, table(Slot))) :-
    write('Bloco '), write(Bloco), write(' na mesa no slot '), write(Slot), nl.
imprimir_elemento(pos(Bloco, on(Outro, Off))) :-
    write('Bloco '), write(Bloco), write(' sobre o bloco '), write(Outro),
    write(' (offset '), write(Off), write(')'), nl.
imprimir_elemento(clear(Bloco)) :-
    write('Topo do bloco '), write(Bloco), write(' esta livre'), nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Visualizacao (mesa em slots) -----------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desenhar_mesa_completa(Estado) :-
    nl, write('=== REPRESENTACAO FISICA ==='), nl,
    table_width(W),
    findall((X,Y,Bloco), posicao_visual(Bloco, Estado, X, Y), Posicoes),
    findall(Y, member((_,Y,_), Posicoes), Ys),
    (Ys = [] -> MaxAltura = 1 ; max_list(Ys, MaxAltura)),
    construir_linhas(MaxAltura, W, Posicoes, Grade),
    imprimir_grade(Grade).

posicao_visual(Bloco, Estado, X, Y) :-
    member(pos(Bloco, table(X0)), Estado),
    tamanho(Bloco, W),
    Fim is X0 + W - 1,
    between(X0, Fim, X),
    Y = 1.
posicao_visual(Bloco, Estado, X, Y) :-
    member(pos(Bloco, on(Suporte, Offset)), Estado),
    coord_esq(Suporte, Estado, Xs),
    posicao_altura(Suporte, Estado, Ys),
    tamanho(Bloco, Wb),
    X0 is Xs + Offset,
    Fim is X0 + Wb - 1,
    between(X0, Fim, X),
    Y is Ys + 1.

coord_esq(Bloco, Estado, X) :-
    member(pos(Bloco, table(X)), Estado), !.
coord_esq(Bloco, Estado, X_B) :-
    member(pos(Bloco, on(Suporte, Offset)), Estado),
    coord_esq(Suporte, Estado, X_Sup),
    X_B is X_Sup + Offset.

posicao_altura(Bloco, Estado, 1) :-
    member(pos(Bloco, table(_)), Estado), !.
posicao_altura(Bloco, Estado, H) :-
    member(pos(Bloco, on(Base, _)), Estado),
    posicao_altura(Base, Estado, H0),
    H is H0 + 1.

construir_linhas(Altura, Largura, Posicoes, Grade) :-
    Altura > 0,
    construir_linha(Altura, Largura, Posicoes, Linha),
    Abaixo is Altura - 1,
    construir_linhas(Abaixo, Largura, Posicoes, GradeAbaixo),
    append([Linha], GradeAbaixo, Grade).
construir_linhas(0, _, _, []).

construir_linha(Altura, Largura, Posicoes, Linha) :-
    construir_linha_slots(0, Largura, Altura, Posicoes, Linha).

construir_linha_slots(X, Largura, _, _, []) :- X >= Largura, !.
construir_linha_slots(X, Largura, Altura, Posicoes, [Cel|R]) :-
    ( member((X,Altura,Bloco), Posicoes) -> Cel = Bloco ; Cel = vazio ),
    X1 is X + 1,
    construir_linha_slots(X1, Largura, Altura, Posicoes, R).

imprimir_grade(Grade) :-
    reverse(Grade, GradeBaixoPraCima),
    forall(member(Linha, GradeBaixoPraCima), (
        write('|'),
        imprimir_celulas(Linha),
        nl
    )),
    write('+'),
    table_width(W),
    forall(between(1, W, _), write('---+')), nl,
    print_indices(0, W).

imprimir_celulas([]).
imprimir_celulas([vazio|R]) :- write('   |'), imprimir_celulas(R).
imprimir_celulas([B|R]) :- format(' ~w |', [B]), imprimir_celulas(R).

print_indices(I, W) :-
    I < W,
    format(' ~w', [I]),
    ( I =:= W - 1 -> nl ; write('   '), I1 is I + 1, print_indices(I1, W) ).
print_indices(W, W) :- nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Interface Interativa Compatível com GNU Prolog ---
%  (Roda UMA vez e encerra)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
    nl,
    write('================================================'), nl,
    write('     PLANEJADOR MUNDO DOS BLOCOS                '), nl,
    write('================================================'), nl,
    write('Escolha uma situacao para visualizar:'), nl,
    write('1. Situacao 1'), nl,
    write('2. Situacao 2'), nl,
    write('3. Situacao 3'), nl,
    write('0. Sair'), nl,
    write('------------------------------------------------'), nl,
    write('Digite o numero da opcao (seguido de ponto e Enter): '), nl,
    read(Opcao),
    executar_opcao_then_exit(Opcao).

% Após executar qualquer opção, encerra (sem voltar ao menu).
executar_opcao_then_exit(0) :-
    write('Encerrando o programa. Ate logo!'), nl, halt.

executar_opcao_then_exit(1) :-
    estado_inicial_s1(S0),
    estado_final_s1(SF),
    write('=== SITUACAO 1 ==='), nl,
    write('Estado inicial:'), nl, imprimir_estado(S0),
    write('Estado final:'), nl, imprimir_estado(SF),
    halt.

executar_opcao_then_exit(2) :-
    estado_inicial_s2(S0),
    estado_final_s2(SF),
    write('=== SITUACAO 2 ==='), nl,
    write('Estado inicial:'), nl, imprimir_estado(S0),
    write('Estado final:'), nl, imprimir_estado(SF),
    halt.

executar_opcao_then_exit(3) :-
    estado_inicial_s3(S0),
    estado_final_s3(SF),
    write('=== SITUACAO 3 ==='), nl,
    write('Estado inicial:'), nl, imprimir_estado(S0),
    write('Estado final:'), nl, imprimir_estado(SF),
    halt.

executar_opcao_then_exit(_) :-
    write('Opcao invalida. O programa sera encerrado.'), nl, halt.

:- initialization(main).