TuranGraph := function(n, r)
  local partition_size, large_partitions, small_partitions, orders;
  # Size of each paritition.
  partition_size := Float(n) / r;
  # Partitions of the larger size
  large_partitions := ListWithIdenticalEntries(n mod r, Int(Ceil(partition_size)));
  # Paritions of the smaller size, to make up for non perfect partitioning
  small_partitions := ListWithIdenticalEntries(r - (n mod r), Int(Floor(partition_size)));
  # orders for multipartite graph
  orders := Concatenation(large_partitions, small_partitions);
  return CompleteMultipartiteDigraph(orders);
end;

MoonMoser := function(n)
  return TuranGraph(n, Int(Ceil(n / 3.0)));
end;
