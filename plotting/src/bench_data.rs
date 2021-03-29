use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct BenchGroup {
    pub group_name: String,
    pub ids: Vec<BenchID>,
}
#[derive(Debug, Serialize, Deserialize)]
pub struct BenchID {
    pub id: String,
    pub entries: Vec<BenchEntry>,
}
#[derive(Debug, Serialize, Deserialize)]
pub struct BenchEntry {
    pub val: f32,
    pub times: Vec<u64>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EvalGroup {
    pub group_name: String,
    pub ids: Vec<EvalID>,
}
#[derive(Debug, Serialize, Deserialize)]
pub struct EvalID {
    pub id: String,
    pub entries: Vec<EvalEntry>,
}
#[derive(Debug, Serialize, Deserialize)]
pub struct EvalEntry {
    pub x: f32,
    pub y: u32,
}
