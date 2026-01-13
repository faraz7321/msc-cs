#import "@preview/diagraph:0.3.6"

== 6.1

=== 1.

#align(
  center,
  diagraph.render(
    "digraph {
	    A -> B;
	    B -> C;
	    C -> D;
	    C -> E;
	    D -> F;
	    E -> F;
	    F -> C;
	    C -> G;
	    G -> B;
	    B -> H;
    }",
  ),
)

=== 2.

$A, B, C, D, F, E, G, H$

=== 3.

$F, D, E, G, C, H, B, A$

=== 4.

$A, B, H, C, G, E, D, F$

=== 5.

```cpp
// n is not const anymore because we need some way of getting the times out
int dfs(std::unordered_set<const Node *> &visited, Node *n, int time) {
    visited.insert(n);
    n->time_pre = time;
    time++;
    for (auto m : n->succs)
        if (visited.find(m) == visited.end())
            time = dfs(visited, m, time);
    n->time_post = time;
    time++;
    return time;
}
```

== 6.2

=== 1. CFG

#stack(dir: ltr,
    {
        let note = x => {
            set text(fill: white, size: 9pt)
            h(-1.2em)
            box(width: 1em, height: 1em, fill: black, radius: 50%, inset: 2pt, x)
            h(0.2em)
        }
            
        [
            #note("1")`A;`\
            #note("2")`while (B && C) {`\
            `   `#note("3")`if (D || E) {`\
            `        `#note("4")`F;`\
            `        continue;`\
            `    }`\
            `    `#note("5")`G;`\
            `    if (H || I) break;`\
            `    `#note("6")`J;`\
            `}`\
            #note("7")`K;   `#note("8")\
        ]
    }
    ,
    diagraph.render(
    `digraph {
        1 -> 2
        2 -> 3
        2 -> 7
        3 -> 4
        4 -> 2
        3 -> 5
        5 -> 7
        5 -> 6
        6 -> 2
        7 -> 8
    }`.text,
    height: 25em,
))

=== 2. Critical Edges

The only critical edge is from 5 to 7. We eliminate it by inserting an extra node:

#align(center, diagraph.render(
    `digraph {
        1 -> 2
        2 -> 3
        2 -> 7
        3 -> 4
        4 -> 2
        3 -> 5
        5 -> new
        new -> 7
        5 -> 6
        6 -> 2
        7 -> 8
    }`.text,
    height: 30em,
))

=== 3. Dominance Tree

#align(center, diagraph.render(
    `digraph {
        1 -> 2
        2 -> 3
        3 -> 4
        3 -> 5
        5 -> 6
        5 -> new
        2 -> 7
        7 -> 8
    }`.text,
    height: 20em,
))

=== 4. Postdominance Tree

#align(center, diagraph.render(
    `digraph {
        8 -> 7
        7 -> new
        7 -> 2
        7 -> 3
        7 -> 5
        2 -> 1
        2 -> 6
        2 -> 4
    }`.text,
    height: 20em,
))

=== 5. Reverse CFG

#align(center, diagraph.render(
    `digraph {
        2 -> 1
        3 -> 2
        7 -> 2
        4 -> 3
        2 -> 4
        5 -> 3
        new -> 5
        7 -> new
        6 -> 5
        2 -> 6
        8 -> 7
    }`.text,
    height: 21em,
))

=== 6. Dominance Frontier Graph

Of the original CFG and not the reverse one i assume?
I'm guessing that this is the graph that has an edge $u -> v$ if v is in the dominance frontier of $u$.

#align(center, diagraph.render(
    `digraph {
        1, 2, 3, 4, 5, 6, 7, 8, new
        2 -> 2
        3 -> 2
        3 -> 7
        5 -> 2
        5 -> 7
        new -> 7
        6 -> 2
        4 -> 2
    }`.text,
    height: 7em,
))

=== 6. Postdominance Frontier Graph

#align(center, diagraph.render(
    `digraph {
        1, 2, 3, 4, 5, 6, 7, 8, new
        2 -> 3
        2 -> 5
        new -> 5
        6 -> 5
        4 -> 3
        3 -> 2
        5 -> 3
    }`.text,
    height: 10em,
))

== 6.3

#let dominates = sym.succ.eq

Dominance is reflexive: Because _all_ paths to $v$ contain $v$, $v$ always dominates itself.

Dominance is transitive: When $u dominates v$ and $v dominates w$, then all paths from $r$ to $w$ include $v$ and all paths from $r$ to $v$ include $u$. So all paths from $r$ to $w$ must also include $u$ somewhere before they reach $v$.

Dominance is anti-symmectric: Assume that $u dominates v$ and $v dominates u$ (and $u != v$). Because of $v dominates u$ every path from $r$ to $u$ contains $v$. Choose any of those paths and take the subpath from $r$ up to the first occurrence of $v$. Because of $u dominates v$, this subpath contains $u$. But then the subpath from $r$ up to that occurrence of $u$ does not contain $v$ (since we picked the first occurrence of $v$ earlier), which contradicts the assumption that $v dominates u$.
