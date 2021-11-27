use std::fs::File;
use std::io::{self, prelude::*, BufReader};
use std::path::Path;

fn main() -> io::Result<()> {
    let filename = Path::new(file!()).parent().unwrap().join("input.txt");
    let file = File::open(filename)?;
    let reader = BufReader::new(file);

    for line in reader.lines() {
        println!("{}", line?);
    }

    Ok(())
}
