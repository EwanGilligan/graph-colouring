Read("bench/bencher.g");
Read("bench/bounds.g");
Read("bench/example_graphs.g");
# Config names
outdir := "data";

# Algorithm groups
all_alg := [
  ChromaticNumber,
  D -> ChromaticNumber(D, DigraphColouringAlgorithmLawler),
  D -> ChromaticNumber(D, DigraphColouringAlgorithmByskov),
  D -> ChromaticNumber(D, DigraphColouringAlgorithmZykov),
  D -> ChromaticNumber(D, DigraphColouringAlgorithmChristofides)
];

all_alg_names := [
  "Baseline",
  "Lawler",
  "Byskov",
  "Zykov",
  "Christofides"
];

mis_alg := [
  ChromaticNumber,
  D -> ChromaticNumber(D, DigraphColouringAlgorithmLawler),
  D -> ChromaticNumber(D, DigraphColouringAlgorithmByskov),
];
mis_alg_names := [
  "Baseline",
  "Lawler",
  "Byskov",
];

bab_alg := [
  ChromaticNumber,
  D -> ChromaticNumber(D, DigraphColouringAlgorithmZykov),
  D -> ChromaticNumber(D, DigraphColouringAlgorithmChristofides)
];
bab_alg_names := [
  "Baseline",
  "Zykov",
  "Christofides"
];

vsr_alg := [
  D -> DigraphColouring(D, ChromaticNumber(D)),
  D -> DigraphColouring(D, DigraphColouringAlgorithmBrelaz),
  D -> DigraphColouring(D, DigraphColouringAlgorithmSegundo),
  D -> DigraphColouring(D, DigraphColouringAlgorithmSewell)
];
vsr_alg_names := [
  "Baseline",
  "Brelaz",
  "Segundo",
  "Sewell"
];

lb_alg := [
  D -> DigraphColouring(D, ChromaticNumber(D)),
  D -> DIGRAPHS_ExactDSATUR(D, dsatur_lb, brelaz_vsr),
  D -> DIGRAPHS_ExactDSATUR(D, clique_lb, brelaz_vsr),
  D -> DIGRAPHS_ExactDSATUR(D, large_clique_lb, brelaz_vsr)
];
lb_alg_names := [
  "Baseline",
  "DSATUR Clique",
  "Maximal Clique",
  "Largest Maximal Clique"
];

lb_val := [
  D -> ChromaticNumber(D),
  D -> dsatur_lb(DigraphSymmetricClosure(D)).lb,
  D -> clique_lb(DigraphSymmetricClosure(D)).lb,
  D -> large_clique_lb(DigraphSymmetricClosure(D)).lb
];
lb_val_names := [
  "Chromatic Number",
  "DSATUR Bound",
  "Maximal Clique Bound",
  "Largest Maximal Clique Bound"
];

greedy_alg := [
  D -> DigraphGreedyColouring(D),
  D -> DigraphGreedyColouring(D, DigraphColouringAlgorithmDSATUR)
];
greedy_alg_names := [
  "Static Ordering",
  "DSATUR Ordering",
];

greedy_bound := [
  D -> ChromaticNumber(D),
  D -> RankOfTransformation(DigraphGreedyColouring(D)),
  D -> RankOfTransformation(DigraphGreedyColouring(D, DigraphColouringAlgorithmDSATUR))
];
greedy_bound_names := [
  "ChromaticNumber",
  "Static Ordering",
  "DSATUR Ordering",
];


################################################################################
# Benchmark Functions 
################################################################################

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
  BenchmarkToFile(bench_group, Concatenation(outdir,
                                             StringFormatted("/CycleDigraphs{}-{}.json", 
                                                             inputs[1], inputs[Length(inputs)])));
end;

BenchMoonMoser := function(inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i, D, name;
  name := StringFormatted("MoonMoser{}-{}", inputs[1], inputs[Length(inputs)]);
  bench_group := NewBenchmarkGroup(name); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := MoonMoser(i);
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], {x} -> D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/", name, ".json"));
end;

BenchDualMoonMoser := function(inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i, D, name;
  name := StringFormatted("DualMoonMoser{}-{}", inputs[1], inputs[Length(inputs)]);
  bench_group := NewBenchmarkGroup(name); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := DigraphRemoveLoops(DigraphDual(MoonMoser(i)));
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], {x} -> D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/", name, ".json"));
end;

BenchRandomDensity := function(n, inputs, algs, alg_names, config, outdir, prefix)
  local bench_group, bench_id, alg_num, i, D, name;
  name := StringFormatted("{}RandomDigraphDensity{}",prefix, n);
  bench_group := NewBenchmarkGroup(name); 
  for alg_num in [1..Length(algs)] do
    Print(alg_names[alg_num], "\n");
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      Print(i, "\n");
      D := p -> DigraphRemoveLoops(RandomDigraph(n, p));
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/",prefix, name, ".json"));
end;

EvalWithRandom := function(n, algs, alg_names, config, outdir, name)
  local bench_group, bench_id, alg_num, i, input_func;
  bench_group := NewBenchmarkGroup(name);
  input_func := function(n)
    local D, x, nr;
    D := DigraphRemoveLoops(RandomDigraph(n));
    nr := DigraphNrVertices(D);
    if IsCompleteDigraph(D) then
      x := 1;
    elif IsNullDigraph(D) then
      x := 0;
    else
      x := Float(DigraphNrEdges(D) / (nr * (nr - 1)));
    fi;
    return rec(x := x, val := D);
  end;
  for alg_num in [1 .. Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    EvalWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], input_func, n); 
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/", name, ".json")); 
end;

BenchRandomSize := function(inputs, algs, alg_names, config, outdir)
  local bench_group, bench_id, alg_num, i, D;
  bench_group := NewBenchmarkGroup("RandomDigrahSize"); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := x -> DigraphRemoveLoops(RandomDigraph(x));
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir,
                                             StringFormatted("/RandomDigraphSize{}-{}.json", 
                                                             inputs[1], inputs[Length(inputs)]
                                                             )
                                            )
                 );
end;


################################################################################
# Specific Runs of Benchmarks
################################################################################

RunUpperBoundsComparison := function(n, rep)
  local name, config; 
  config := NewBenchmarkConfig(0, rep);
  name := StringFormatted("UpperBoundsComparison{}", n);
  EvalWithRandom(n, greedy_bound, greedy_bound_names, config, outdir, name);
end;

RunLowerBoundsComparison := function(n, rep)
  local name, config; 
  config := NewBenchmarkConfig(0, rep);
  name := StringFormatted("LowerBoundsComparison{}", n);
  EvalWithRandom(n, lb_val, lb_val_names, config, outdir, name);
end;

RunBoundsComparison := function()
  Print("Upper Bounds Comparison\n");
  RunUpperBoundsComparison(20, 1000);
  RunUpperBoundsComparison(40, 1000);
  RunUpperBoundsComparison(60, 1000);
  RunUpperBoundsComparison(80, 500);
  # TODO try compare across sizes
  Print("Lower Bounds Comparison\n");
  RunLowerBoundsComparison(20, 1000);
  RunLowerBoundsComparison(40, 1000);
end;

RunUpperBoundsBench := function() 
  local config, probabilities;
  probabilities := [0.1, 0.2, 0.3, 0.4, 0.50, 0.6,
                    0.7, 0.8, 0.9];
  config := NewBenchmarkConfig(10, 100); 
  Print("Upper Bounds Bench\n");
  BenchRandomDensity(60, probabilities, greedy_alg, greedy_alg_names,config, outdir, "UpperBounds"); 
  BenchRandomDensity(80, probabilities, greedy_alg, greedy_alg_names,config, outdir, "UpperBounds"); 
  BenchRandomDensity(100, probabilities, greedy_alg, greedy_alg_names,config, outdir, "UpperBounds"); 
  BenchRandomSize(List([20 .. 120]), greedy_alg, greedy_alg_names, config, outdir);
end;

RunLowerBoundsBench := function() 
  local config, probabilities, high_probs;
  probabilities := [0.1, 0.2, 0.3, 0.4, 0.50, 0.6,
                    0.7, 0.8, 0.9];

  high_probs := [0.7, 0.75, 0.8, 0.85, 0.9, 0.95];
  config := NewBenchmarkConfig(10, 50); 
  Print("Lower Bounds Bench\n");
  BenchRandomDensity(20, probabilities, lb_alg, lb_alg_names,config, outdir, "LowerBounds"); 
  BenchRandomDensity(30, high_probs, lb_alg, lb_alg_names,config, outdir, "LowerBounds"); 
  # Benchmark with different timings
end;

RunCycleBench := function()
  local config;
  Print("Cycle Bench\n");
  config := NewBenchmarkConfig(10, 100);
  BenchCycles(List([3, 5 .. 13]), all_alg, all_alg_names, config, outdir); 
  BenchCycles(List([3, 5 .. 25]), bab_alg, bab_alg_names, config, outdir);
end;

RunMoonMoser := function()
  local config;
  Print("Moon Moser\n");
  config := NewBenchmarkConfig(10, 100); 
  # Moon Moser benches
  BenchMoonMoser(List([6 .. 15]), mis_alg, mis_alg_names, config, outdir);
  BenchMoonMoser(List([6 .. 39]), bab_alg, bab_alg_names, config, outdir);
  Print("Dual Moon Moser\n");
  # Dual Moon Moser Benches
  BenchDualMoonMoser(List([6 .. 15]), mis_alg, mis_alg_names, config, outdir);
  BenchDualMoonMoser(List([12 .. 18]), bab_alg, bab_alg_names, config, outdir);
end;

RunRandom := function()
  local inputs, config, probabilities, small_config;
  Print("Random Comparison\n");
  # Setup
  probabilities := [0.1, 0.2, 0.3, 0.4, 0.50, 0.6,
                    0.7, 0.8, 0.9];
  config := NewBenchmarkConfig(10, 100); 
  small_config := NewBenchmarkConfig(5, 50); 
  # Run benches
  BenchRandomDensity(10, probabilities, mis_alg, mis_alg_names, config, outdir, "MIS");
  BenchRandomDensity(15, probabilities, mis_alg, mis_alg_names, config, outdir, "MIS");
  BenchRandomDensity(20, probabilities, bab_alg, bab_alg_names, config, outdir, "BAB");
  BenchRandomDensity(30, probabilities, bab_alg, bab_alg_names, config, outdir, "BAB");
  BenchRandomDensity(40, probabilities, bab_alg, bab_alg_names, small_config, outdir, "BAB");
end;

RunVSR := function()
  local probabilities, config, high_probs;
  Print("VSR Comparison\n");
  probabilities := [0.1, 0.2, 0.3, 0.4, 0.50, 0.6,
                    0.7, 0.8, 0.9];
  high_probs := [0.7, 0.75, 0.8, 0.85, 0.9, 0.95];
  config := NewBenchmarkConfig(10, 50); 
  BenchRandomDensity(20, probabilities, vsr_alg, vsr_alg_names,config, outdir, "VSR"); 
  BenchRandomDensity(25, probabilities, vsr_alg, vsr_alg_names,config, outdir, "VSR"); 
  BenchRandomDensity(30, probabilities, vsr_alg, vsr_alg_names,config, outdir, "VSR"); 
  BenchRandomDensity(40, high_probs, vsr_alg, vsr_alg_names,config, outdir, "VSR"); 
end;

RunAll := function()
  # Cycle Benches 
  RunCycleBench();
  # Moon Moser
  RunMoonMoser();
  # Random Benches
  RunRandom();
  # Bounds Checking 
  RunBoundsComparison();
  RunUpperBoundsBench();
  RunLowerBoundsBench();
  # VSR Comparison
  RunVSR();
end;
