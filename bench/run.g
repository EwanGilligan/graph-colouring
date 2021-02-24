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

BenchRandomDensity := function(n, inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i, D;
  bench_group := NewBenchmarkGroup("RandomDigraphDensity"); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := p -> DigraphRemoveLoops(RandomDigraph(n, p));
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/RandomDigraphDensity.json"));
end;


RunAll := function()
  local inputs, config, algs, alg_names, outdir, probabilities;
  # Setup
  inputs := [11, 13, 15, 17, 19, 21, 23, 25];
  probabilities := [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.50, 0.55, 0.6,
                   0.65, 0.75, 0.85, 0.9, 0.95];
  config := NewBenchmarkConfig(10, 100); 
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
  BenchRandomDensity(30, probabilities, algs, alg_names, config, outdir);
end;

RunRandom := function()
  local inputs, config, algs, alg_names, outdir, probabilities;
  # Setup
  probabilities := [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.50, 0.55, 0.6,
                   0.65, 0.75, 0.85, 0.9, 0.95];
  config := NewBenchmarkConfig(10, 100); 
  algs := [
    D -> ChromaticNumber(D, DigraphColouringAlgorithmChristofides),
  ];
  alg_names := [
    "Christofides"
  ];
  outdir := "data";
  # Run benches
  BenchRandomDensity(25, probabilities, algs, alg_names, config, outdir);
end;
