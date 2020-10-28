LoadPackage("digraphs");

IndexSubsets := function(vertices) 
    return Sum(vertices, x-> 2^(x-1)) + 1;
end;

Lawler := function(g) 
    local n, vertices, x, s, S, maximal_independent_sets, i, I, s_without_I, subset_iter, count, induced_subgraph;
    n := DigraphNrVertices(g);
    vertices := DigraphVertices(g);
    x := [1..2^n];
    x[1] := 0;
    subset_iter := IteratorOfCombinations(vertices);
    # Skip the first one, which should be the empty set.
    NextIterator(subset_iter);
    for s in subset_iter do
        S := IndexSubsets(s);
        x[S] := infinity;
        induced_subgraph := InducedSubdigraph(g, s);
        for I in DigraphMaximalIndependentSets(induced_subgraph) do
            s_without_I := ShallowCopy(s);
            # Need to relabl the independent set back to the original labels.
            SubtractSet(s_without_I, SetX(I, x -> DigraphVertexLabel(induced_subgraph, x)));
            i := IndexSubsets(s_without_I);
            if x[i] + 1 < x[S] then
                x[S] := x[i] + 1;
            fi;
        od;
    od;
    return x[2^n]; 
end;
