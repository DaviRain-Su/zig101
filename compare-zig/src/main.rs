fn main() {
    println!("Hello, world!");
    let result = add(5, 3);
    println!("Result: {}", result);
}

pub fn add<T>(a: T, b: T) -> T
where
    T: std::ops::Add<Output = T>,
{
    a + b
}
