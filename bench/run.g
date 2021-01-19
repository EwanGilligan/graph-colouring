Bench_Cycles := function(inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i;
  bench_group := NewBenchmarkGroup("CycleDigraphs"); 
  for alg_num in [1..Length(algs)] do
    bench_id := NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir + "/CycleDigraphs"));
end;
