dsatur_lb := function(D)
  local init_colouring, lb, ub, clique;
  # Initial greedy colouring for upper and lower bounds.
  init_colouring := DIGRAPHS_GreedyDSATUR(D);
  # Lower bound is clique number from initial colouring.
  lb := Length(init_colouring[2]);
  # Upper bound is colours used in greedy colouring.
  ub := RankOfTransformation(init_colouring[1]);
  # Initial clique in the graph
  clique := init_colouring[2];
  init_colouring := ListX(DigraphVertices(D), x -> x ^ init_colouring[1]);
  return rec(init_colouring := init_colouring,
             clique := clique,
             lb := lb,
             ub := ub);
end;

clique_lb := function(D)
  local init_colouring, lb, ub, clique;
  # Initial greedy colouring for upper and lower bounds.
  init_colouring := DIGRAPHS_GreedyDSATUR(D);
  # Upper bound is colours used in greedy colouring.
  ub := RankOfTransformation(init_colouring[1]);
  # Initial clique in the graph
  clique := DigraphMaximalClique(D);
  lb := Length(clique);
  init_colouring := ListX(DigraphVertices(D), x -> x ^ init_colouring[1]);
  return rec(init_colouring := init_colouring,
             clique := clique,
             lb := lb,
             ub := ub);
end;

large_clique_lb := function(D)
  local init_colouring, lb, ub, clique, cliques, i;
  # Initial greedy colouring for upper and lower bounds.
  init_colouring := DIGRAPHS_GreedyDSATUR(D);
  # Upper bound is colours used in greedy colouring.
  ub := RankOfTransformation(init_colouring[1]);
  # Initial clique in the graph
  cliques := DigraphMaximalCliques(D);
  clique := cliques[PositionMaximum(List(cliques, Length))];
  lb := Length(clique);
  init_colouring := ListX(DigraphVertices(D), x -> x ^ init_colouring[1]);
  return rec(init_colouring := init_colouring,
             clique := clique,
             lb := lb,
             ub := ub);
end;


brelaz_vsr := function(D, vertices, colouring, k)
  local v, u, cur_deg, min_deg;
  min_deg := infinity;
  for u in vertices do
    cur_deg := OutDegreeOfVertex(D, u);
    if cur_deg < min_deg then
      v := u;
      min_deg := cur_deg;
    fi;
  od;
  # Further ties broken in ascending order, and vertices are visited in
  # ascending order and so cur is visited before new.
  return v;
end;


