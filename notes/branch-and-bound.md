# Branch and Bound

## Zykov's

* Corniel and Graham for Zykov's.
* It is an optimisation of Zykov's that uses branch and bound to bound the
search tree produced by the Zykov tree.
* The variable ordering may be tricky to get right. You have to choose two adjacent
verticies x and y, but that could drastically alter the tree. Would be good to investigate.
* better to find clusters instead of cliques, as clique finding is np complete.
May be better for practical use to just check for cliques, as the clique finding
is a method of the gap kernel.
