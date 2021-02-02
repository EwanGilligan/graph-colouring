use plotters::prelude::*;
use stats::{mean, stddev};
use std::fs::File;
use std::io::BufReader;
mod bench_data;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let colours = vec![&BLACK, &BLUE, &CYAN, &GREEN, &MAGENTA, &RED];
    let mut colour_iter = colours.iter().cycle();
    let data: bench_data::BenchGroup =
        read_data("../data/RandomDigraphDensityChristofidesBlistComparison.json")?;
    let plotting_data: Vec<(String, Vec<_>)> = data
        .ids
        .iter()
        .map(|id| {
            (
                id.id.clone(),
                id.entries
                    .iter()
                    .map(|ent| {
                        let mean = mean(ent.times.iter().cloned());
                        let devs = stddev(ent.times.iter().cloned());
                        (ent.val, mean - devs, mean, mean + devs)
                    })
                    .collect(),
            )
        })
        .collect();
    //Find max values for plotting range.
    let y_max = plotting_data
        .iter()
        .flat_map(|x| x.1.iter().map(|(_x, _min, _mean, max)| *max))
        .fold(f64::NEG_INFINITY, |a, b| a.max(b));
    let x_max = plotting_data
        .iter()
        .flat_map(|x| x.1.iter().map(|(x, _min, _mean, _max)| *x))
        .fold(f32::NEG_INFINITY, |a, b| a.max(b));
    let root = BitMapBackend::new("test.png", (1024, 768)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        .caption(data.group_name, ("sans-serif", 40).into_font())
        .margin(40)
        .x_label_area_size(20)
        .y_label_area_size(30)
        .set_label_area_size(LabelAreaPosition::Left, 40)
        .set_label_area_size(LabelAreaPosition::Bottom, 40)
        .build_cartesian_2d(0f32..x_max, 0f64..y_max)?;
    chart
        .configure_mesh()
        .x_labels(5)
        .x_desc("p")
        .y_labels(5)
        .y_label_formatter(&|y| format!("{:+e}", y))
        .y_desc("Mean Time (ns)")
        .draw()?;
    for (name, id) in &plotting_data {
        let colour = colour_iter.next().expect("cycle iterator").clone();
        // Line Series
        chart.draw_series(LineSeries::new(
            id.iter().map(|(x, _min, mean, _max)| (*x, *mean)),
            colour.clone(),
        ))?;
        // Point Series
        chart
            .draw_series(id.iter().map(|&(x, ymin, ymean, ymax)| {
                ErrorBar::new_vertical(x, ymin, ymean, ymax, colour.clone().filled(), 5)
            }))?
            .label(name)
            .legend(move |(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], colour.filled()));
    }
    chart
        .configure_series_labels()
        .background_style(WHITE.filled())
        .border_style(&BLACK)
        .draw()?;
    Ok(())
}

fn read_data(filename: &str) -> Result<bench_data::BenchGroup, Box<dyn std::error::Error>> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);
    let data: bench_data::BenchGroup = serde_json::from_reader(reader)?;
    Ok(data)
}
