#set page(width: 29.7cm, height: 21cm)

=== 4.1  From a Grammar to an LL(1) Parser

1. Eliminating left recursion

  The grammar
  $S -> id(L) space | space S ; id(L)$, $L -> epsilon space | space M$, $M -> id space | space M , id$
  has immediate left recursion in $S$ and $M$.
  Introducing helpers $S'$ and $M'$ yields the equivalent right-recursive grammar:
  $S -> id(L) S'$, $S' -> ; id(L) S' space | space epsilon$,
  $L -> M space | space epsilon$, $M -> id M'$, $M' -> , id M' space | space epsilon$.
  To parse the whole input, extend it with $S_0 -> S \#$.

2. FIRST\_1 and FOLLOW\_1

  FIRST sets:
  - FIRST$(S_0) = { id }$ (through $S$)
  - FIRST$(S) = { id }$
  - FIRST$(S') = { ;, epsilon }$
  - FIRST$(L) = { id, epsilon }$
  - FIRST$(M) = { id }$
  - FIRST$(M') = { ,, epsilon }$

  FOLLOW sets (using $S_0$ as start symbol):
  - FOLLOW$(S_0) = { \# }$
  - FOLLOW$(S) = { \# }$
  - FOLLOW$(S') = { \# }$ (end of $S$)
  - FOLLOW$(L) = { ) }$ (always followed by a right parenthesis)
  - FOLLOW$(M) = { ) }$ (because $L -> M$)
  - FOLLOW$(M') = { ) }$

3. LL(1) parse table (rows = non-terminals, columns = lookahead)

```
          |   id   |   (   |   )   |   ;     |   ,   |   #
----------+--------+-------+-------+---------+-------+-------
S0        | S #    |       |       |         |       |
S         | id(L)S'|       |       |         |       |
S'        |        |       |       | ;id(L)S'|       |   ε
L         | M      |       |  ε    |         |       |
M         | id M'  |       |       |         |       |
M'        |        |       |  ε    |         | ,idM' |
```

No entry has two productions, so the grammar is LL(1).

4. Successful LL(1) run for `id();id(id,id)#`

  Stack is written bottom-to-top from left to right; the top of stack is on the right.

```
step | stack               | input                       | action
---- | ------------------- | --------------------------- | --------------------------
 0   | S0                  | id ( ) ; id ( id , id ) #   | start
 1   | # S                 | id ( ) ; id ( id , id ) #   | expand S0 -> S #
 2   | # S' ) L ( id       | id ( ) ; id ( id , id ) #   | expand S -> id(L)S'
 3   | # S' ) L (          | ( ) ; id ( id , id ) #      | match id
 4   | # S' ) L            | ) ; id ( id , id ) #        | match (
 5   | # S' )              | ) ; id ( id , id ) #        | L -> ε (lookahead ')')
 6   | # S'                | ; id ( id , id ) #          | match )
 7   | # S' ) L ( id ;     | ; id ( id , id ) #          | expand S' -> ;id(L)S'
 8   | # S' ) L ( id       | id ( id , id ) #            | match ;
 9   | # S' ) L (          | ( id , id ) #               | match id
10   | # S' ) L            | id , id ) #                 | match (
11   | # S' ) M            | id , id ) #                 | L -> M
12   | # S' ) M' id        | id , id ) #                 | expand M -> id M'
13   | # S' ) M'           | , id ) #                    | match id
14   | # S' ) M' id ,      | , id ) #                    | M' -> ,idM'
15   | # S' ) M' id        | id ) #                      | match ,
16   | # S' ) M'           | ) #                         | match id
17   | # S' )              | ) #                         | M' -> ε
18   | # S'                | #                           | match )
19   | #                   | #                           | S' -> ε
20   |                     |                             | match # / accept
```

The input is fully consumed and the stack empties after the end marker, so the run succeeds.

=== 4.2  Item Pushdown Automaton

Grammar with synthetic start: $S' -> S$, $S -> a B$, $A -> B space | space epsilon$, $B -> b B a space | space a A$.
Input word: `"abaa"`.
Items use a dot to mark the current position.

```
step | stack (bottom → top)                                       | remaining input | action
---- | --------------------------------------------               | ---------------- | -------------------------------
 0   | [S' → . S]                                                 | abaa             | expand start
 1   | [S' → . S] [S → . a B]                                     | abaa             | expand S
 2   | [S' → . S] [S → a . B]                                     | baa              | shift 'a'
 3   | [S' → . S] [S → a . B] [B → . b B a]                       | baa              | expand B with 'b' branch
 4   | [S' → . S] [S → a . B] [B → b . B a]                       | aa               | shift 'b'
 5   | [S' → . S] [S → a . B] [B → b . B a] [B → . a A]           | aa               | expand inner B with 'a'
 6   | [S' → . S] [S → a . B] [B → b . B a] [B → a . A]           | a                | shift 'a'
 7   | [S' → . S] [S → a . B] [B → b . B a] [B → a . A] [A → .]   | a                | expand A -> ε
 8   | [S' → . S] [S → a . B] [B → b . B a] [B → a A .]           | a                | reduce A
 9   | [S' → . S] [S → a . B] [B → b B . a]                       | a                | reduce inner B
10   | [S' → . S] [S → a . B] [B → b B a .]                       |                  | shift 'a'
11   | [S' → . S] [S → a B .]                                     |                  | reduce outer B
12   | [S' → S .]                                                 |                  | reduce S and accept
```

The final stack `[S' → S .]` proves the item PDA accepts the input `abaa`.
