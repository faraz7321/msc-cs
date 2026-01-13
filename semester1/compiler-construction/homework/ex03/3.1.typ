=== 3.1

==== 1.

The Grammar $S -> A, A -> "a"^k "b" | "a"^k c$ is $"LL"(k+1)$, because there are no words $u x$ and $u y$ with $(k + 1) : x = (k + 1) : y)$, but not $"LL"(k)$, because $k:"a"^k b = k:"a"^k c$, but not $beta = gamma$.

==== 2.

For every $"LL"(k)$ grammar: $k:x = k:y => beta = gamma$. Also, $(k+1):x = (k+1):y => k:x = k:y$, so $(k+1):x = (k+1):y => beta = gamma$ also holds for the $"LL"(k)$ grammar.

==== 3.

An $"LL"(0)$ grammar can have at most 1 word, as every production has to always produce the same result.

==== 4.

The grammar has no non-productive terminals, so there are also productions for $A ==>^*_(l m) w$ for some $w in V_T^*$. Then:

$
S ==>^*_(l m) u A mu^k ==>_(l m) u A mu mu^k ==>^*_(l m) u w mu^(k+1) \

S ==>^*_(l m) u A mu^k ==>^*_(l m) u w mu^k
$

with $k:w mu^(k+1) = w mu^k$, but $A mu != w$.
