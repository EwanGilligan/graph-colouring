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
  D -> DIGRAPHS_ExactDSATUR(D, clique_lb, brelaz_vsr)
];
lb_alg_names := [
  "Baseline",
  "DSATUR Clique",
  "Maximal Clique"
];

lb_val := [
  D -> ChromaticNumber(D),
  D -> dsatur_lb(DigraphSymmetricClosure(D)).lb,
  D -> clique_lb(DigraphSymmetricClosure(D)).lb
];
lb_val_names := [
  "Chromatic Number",
  "DSATUR Bound",
  "Maximal Clique Bound"
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

# Benchmark functions
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
  local bench_group, bench_id, alg_num, i, D, name;
  name := StringFormatted("RandomDigraphDensity{}", n);
  bench_group := NewBenchmarkGroup(name); 
  for alg_num in [1..Length(algs)] do
    NewBenchmarkId(bench_group, alg_names[alg_num]); 
    for i in inputs do
      D := p -> DigraphRemoveLoops(RandomDigraph(n, p));
      BenchWithInput(config, bench_group, alg_names[alg_num], algs[alg_num], D, i);   
    od;
  od;
  BenchmarkToFile(bench_group, Concatenation(outdir, "/", name, ".json"));
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

RunUpperBoundsComparison := function(n)
  local name, config; 
  config := NewBenchmarkConfig(0, 1000);
  name := StringFormatted("UpperBoundsComparison{}", n);
  EvalWithRandom(n, greedy_bound, greedy_bound_names, config, outdir, name);
end;

RunLowerBoundsComparison := function(n)
  local name, config; 
  config := NewBenchmarkConfig(0, 1000);
  name := StringFormatted("LowerBoundsComparison{}", n);
  EvalWithRandom(n, lb_val, lb_alg_names, config, outdir, name);
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
  # Run benches
  BenchCycles(inputs, algs, alg_names, config, outdir);
  BenchRandomDensity(30, probabilities, algs, alg_names, config, outdir);
end;

RunRandom := function(n)
  local inputs, config, algs, alg_names, outdir, probabilities;
  # Setup
  probabilities := [0.1, 0.2, 0.3, 0.4, 0.50, 0.6,
                    0.7, 0.8, 0.9];
  config := NewBenchmarkConfig(10, 50); 
  algs := [
    D -> ChromaticNumber(D, DigraphColouringAlgorithmChristofides),
    D -> ChromaticNumber(D, DigraphColouringAlgorithmZykov)
  ];
  alg_names := [
    "Christofides",
    "Zykov"
  ];
  # Run benches
  BenchRandomDensity(n, probabilities, algs, alg_names, config, outdir);
end;
