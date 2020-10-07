LoadPackage("digraphs");

IndexSubsets := function(vertices) 
    return Sum(vertices, x-> 2^(x-1));
end;

Lawler := function(g) 
    local n, vertices, x, subset, s, S, maximal_independent_sets, independent_set, i, I;
    n := DigraphNrEdges(g);
    vertices := DigraphVertices(g);
    x := [1..2^n];
    x[0] := 0;
    for s in [2..2^n] do
        S := IndexSubsets(s);
        x[S] := infinity;
        maximal_independent_sets := DigraphIndependentSet(g, vertices{[1..s]});
        for I in maximal_independent_sets do
            i := IndexSubsets(SubtractSet(S, I));
            if x[i] + 1 < x[s] then
                x[s] := x[i] + 1;
            fi;
        od;
    od;
    return X[-1];
end;