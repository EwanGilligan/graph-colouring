use plotters::{prelude::*};
use std::fs::File;
use std::io::BufReader;

mod bench_data;
fn main() -> Result<(), Box<dyn std::error::Error>>{
    
    let data : bench_data::BenchGroup = read_data("../test.json")?;
    println!("{:?}", data);
    let root = BitMapBackend::new("test.png", (640, 480)).into_drawing_area();
    let root = root.margin(10, 10, 10, 10);
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        .caption("test", ("sans-serif", 40).into_font())
        .x_label_area_size(20)
        .y_label_area_size(40)
        .build_cartesian_2d(0f32..20f32, 0f32..100000f32)?;
    chart
        .configure_mesh()
        .x_labels(5)
        .y_labels(5)
        .draw()?;
    for id in &data.ids {
        chart.draw_series(PointSeries::of_element(
            id.entries.iter()
                    .map(|ent| {
                        let mean = ent.times.iter().map(|x| x.clone()).sum::<u64>() as f32 / ent.times.len() as f32;
                        (ent.val as f32, mean)
                    }),
            2, 
           &BLACK,
            &|c, s, st| {
                return EmptyElement::at(c)
                       + Circle::new((0,0), s, st.filled())
                       + Text::new(format!("{:?}", c), (10,0), ("sans-serif", 10).into_font());
            },
        ))?;
    }
    Ok(())
}

fn read_data(filename : &str) -> Result<bench_data::BenchGroup, Box<dyn std::error::Error>> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);
    let data : bench_data::BenchGroup = serde_json::from_reader(reader)?;
    Ok(data)
}
