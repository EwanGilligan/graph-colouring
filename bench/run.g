BenchCycles := function(inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i, D;
  bench_group := NewBenchmarkGroup("CycleDigraphs"); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := CycleDigraph(i);
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], {x} -> D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/CycleDigraphs.json"));
end;

RunAll := function()
  local inputs, config, algs, alg_names, outdir;
  # Setup
  inputs := [11, 13, 15, 17, 19, 21, 23, 25];
  config := NewBenchmarkConfig(5, 10); 
  algs := [
    ChromaticNumber,
    D -> ChromaticNumber(D, DigraphColouringAlgorithmZykov)
  ];
  alg_names := [
    "Baseline",
    "Zykov"
  ];
  outdir := "data";
  # Run benches
  BenchCycles(inputs, algs, alg_names, config, outdir);
end;
