check_all_graphs := function(filename, algorithm) 
  local file, iter, graph;
  Print("Starting Test\n");
  iter := IteratorFromDigraphFile(filename);
  for graph in iter do
    if not ChromaticNumber(graph) = ChromaticNumber(graph, algorithm) then
      Print(graph);
    fi;
  od;
  Print("Done\n");
end;
