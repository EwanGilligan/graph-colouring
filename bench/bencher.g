LoadPackage("io");
LoadPackage("json");

TimeFunc := function(config, func, input)
  local times, time_start, time_end, i;
# Warmup Computation 
  for i in [1..config.warmup] do
    func(input);
  od;
  GASMAN("collect");
  times := [];
  for i in [1..config.repetitions] do 
    time_start := NanosecondsSinceEpoch();
    func(input);
    time_end := NanosecondsSinceEpoch();
    Add(times, time_end - time_start);
  od;
  return times;
end;

BenchWithInput := function(config, group, id, func, input) 
  local i, group_id_input, id_entry;
    # Benchmark
  group_id_input := rec(val := input, times := TimeFunc(config, func, input));
  id_entry := First(group.ids, x -> x.id = id);
  Add(id_entry.entries, group_id_input); 
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
