use plotters::prelude::*;
use stats::{mean, stddev};
use std::env;
use std::fs::File;
use std::io::BufReader;
mod bench_data;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<_> = env::args().collect();
    let plot_type = &args[1];
    let plot_file = &args[2];
    if plot_type == "p" {
        return probability_plot(&plot_file[..]);
    } else if plot_type == "n" {
        return n_plot(&plot_file[..]);
    } else if plot_type == "d" {
        return density_plot(&plot_file[..]);
    }
    Ok(())
}

fn n_plot(filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let colours = vec![&BLUE, &GREEN, &MAGENTA, &RED, &CYAN, &BLACK];
    let mut colour_iter = colours.iter().cycle();
    print!("{}", filename);
    let data: bench_data::BenchGroup = read_data(filename)?;
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
        .flat_map(|x| x.1.iter().map(|(x, _min, _mean, _max)| *x as i32))
        .max()
        .expect("Must be at least one point");
    let plotname = format!("plots/{}.png", data.group_name);
    let root = BitMapBackend::new(&plotname, (1024, 768)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        //       .caption(data.group_name, ("sans-serif", 40).into_font())
        .margin(40)
        .x_label_area_size(20)
        .y_label_area_size(30)
        .set_label_area_size(LabelAreaPosition::Left, 60)
        .set_label_area_size(LabelAreaPosition::Bottom, 40)
        .build_cartesian_2d(0i32..(x_max + 1), 0f64..y_max)?;
    chart
        .configure_mesh()
        .x_labels(10)
        .x_desc("n")
        .y_labels(5)
        .y_label_formatter(&|y| format!("{:+e}", y))
        .y_desc("Mean Time (ns)")
        .draw()?;
    for (name, id) in &plotting_data {
        let colour = colour_iter.next().expect("cycle iterator").clone();
        // Line Series
        chart.draw_series(LineSeries::new(
            id.iter().map(|(x, _min, mean, _max)| (*x as i32, *mean)),
            colour.clone(),
        ))?;
        // Point Series
        chart
            .draw_series(id.iter().map(|&(x, ymin, ymean, ymax)| {
                ErrorBar::new_vertical(x as i32, ymin, ymean, ymax, colour.clone().filled(), 5)
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

fn probability_plot(filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let colours = vec![&BLUE, &GREEN, &MAGENTA, &RED, &CYAN, &BLACK];
    let mut colour_iter = colours.iter().cycle();
    let data: bench_data::BenchGroup = read_data(filename)?;
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
    let plotname = format!("plots/{}.png", data.group_name);
    let root = BitMapBackend::new(&plotname, (1024, 768)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        //       .caption(data.group_name, ("sans-serif", 40).into_font())
        .margin(40)
        .x_label_area_size(20)
        .y_label_area_size(30)
        .set_label_area_size(LabelAreaPosition::Left, 60)
        .set_label_area_size(LabelAreaPosition::Bottom, 40)
        .build_cartesian_2d(0f32..1.0, 0f64..y_max)?;
    chart
        .configure_mesh()
        .x_labels(10)
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

fn density_plot(filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let colours = vec![&BLUE, &GREEN, &MAGENTA, &RED, &CYAN, &BLACK];
    let mut colour_iter = colours.iter().cycle();
    let data: bench_data::EvalGroup = read_eval_data(filename)?;
    let plotting_data: Vec<(String, Vec<_>)> = data
        .ids
        .iter()
        .map(|id| {
            (
                id.id.clone(),
                id.entries
                    .iter()
                    .map(|ent| (ent.x.clone(), ent.y.clone()))
                    .collect(),
            )
        })
        .collect();
    //Find max values for plotting range.
    let y_max = plotting_data
        .iter()
        .flat_map(|x| x.1.iter().map(|(_x, y)| *y))
        .max()
        .expect("Must be at least one data point");
    let plotname = format!("plots/{}.png", data.group_name);
    let root = BitMapBackend::new(&plotname, (1024, 768)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        //       .caption(data.group_name, ("sans-serif", 40).into_font())
        .margin(40)
        .x_label_area_size(20)
        .y_label_area_size(30)
        .set_label_area_size(LabelAreaPosition::Left, 60)
        .set_label_area_size(LabelAreaPosition::Bottom, 40)
        .build_cartesian_2d(0f32..1.0, 0u32..(y_max + 1))?;
    chart
        .configure_mesh()
        .x_labels(10)
        .x_desc("Edge Density")
        .y_labels(5)
        .y_desc("Bound Value")
        .draw()?;
    for (name, id) in &plotting_data {
        let colour = colour_iter.next().expect("cycle iterator").clone();
        // Point Series
        chart
            .draw_series(
                id.iter()
                    .map(|&(x, y)| Circle::new((x, y), 1, colour.clone().filled())),
            )?
            .label(name)
            .legend(move |(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], colour.filled()));
    }
    chart
        .configure_series_labels()
        .position(SeriesLabelPosition::MiddleLeft)
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

fn read_eval_data(filename: &str) -> Result<bench_data::EvalGroup, Box<dyn std::error::Error>> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);
    let data: bench_data::EvalGroup = serde_json::from_reader(reader)?;
    Ok(data)
}
