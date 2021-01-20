use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct BenchGroup {
    pub group_name : String,
    pub ids : Vec<BenchID>
}
#[derive(Debug, Serialize, Deserialize)]
pub struct BenchID {
    pub id : String,
    pub entries : Vec<BenchEntry>
}
#[derive(Debug, Serialize, Deserialize)]
pub struct BenchEntry {
    pub val : f32,
    pub times : Vec<u64>
}