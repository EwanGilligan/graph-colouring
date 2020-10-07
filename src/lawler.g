LoadPackage("digraphs");

IndexSubsets := function(vertices) 
    return Sum(vertices, x-> 2^(x-1) + 1);
end;

Lawler := function(g) 
    local n, vertices, x, s, S, maximal_independent_sets, i, I, s_without_I, subset_iter;
    n := DigraphNrEdges(g);
    vertices := DigraphVertices(g);
    x := [1..2^n];
    x[1] := 0;
    subset_iter := IteratorOfCombinations(vertices);
    # Skip the first one, which should be the empty set.
    NextIterator(subset_iter);
    for s in subset_iter do
        S := IndexSubsets(s);
        x[S] := infinity;
        maximal_independent_sets := DigraphMaximalIndependentSets(g, s);
        for I in maximal_independent_sets do
            s_without_I := ShallowCopy(s);
            SubtractSet(s_without_I, I);
            i := IndexSubsets(s_without_I);
            if x[i] + 1 < x[S] then
                x[S] := x[i] + 1;
            fi;
        od;
    od;
    return x[-1];
end;