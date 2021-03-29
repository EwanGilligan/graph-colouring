LoadPackage("io", false);
LoadPackage("json", false);

TimeFunc := function(config, func, input_func, input)
  local times, time_start, time_end, i, input_val;
  GASMAN("collect");
  times := [];
  for i in [1..(config.repetitions + config.warmup)] do 
    input_val := input_func(input); 
    time_start := NanosecondsSinceEpoch();
    func(input_val);
    time_end := NanosecondsSinceEpoch();
    # Warmup Computation 
    if i > config.warmup then
      Add(times, time_end - time_start);
    fi;
  od;
  return times;
end;

EvalFunc := function(config, func, input_func, input)
  local values, val, i, input_val;
  values := [];
  for i in [1..config.repetitions] do 
    input_val := input_func(input); 
    val := func(input_val.val);
    Add(values, rec(x := input_val.x, y := val)); 
  od;
  return values;
end;

BenchWithInput := function(config, group, id, func, input_func, input) 
  local i, group_id_input, id_entry;
    # Benchmark
  group_id_input := rec(val := input, times := TimeFunc(config, func, input_func, input));
  id_entry := First(group.ids, x -> x.id = id);
  Add(id_entry.entries, group_id_input); 
end;

EvalWithInput := function(config, group, id, func, input_func, input) 
  local i, group_id_input, id_entry;
  group_id_input := EvalFunc(config, func, input_func, input);
  id_entry := First(group.ids, x -> x.id = id);
  id_entry.entries := group_id_input; 
end;

NewBenchmarkGroup := function(group_name_string)
  return rec(group_name := group_name_string, ids := []);
end;

NewBenchmarkId := function(group, id)
  local id_entry;
  id_entry := rec(id := id, entries := []);
  Add(group.ids, id_entry);
end;

NewBenchmarkConfig := function(warmup, repetitions)
  return rec(warmup := warmup, repetitions := repetitions);
end;

BenchmarkToFile := function(group, filename)
  local fd, json_string;
  fd := IO_File(filename, "w");
  json_string := GapToJsonString(group);
  IO_Write(fd, json_string);
  IO_Close(fd);
end;
