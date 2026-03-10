impl Solution {
    pub fn roman_to_int(s: String) -> i32 {
        let mut result = 0;
        let mut highest_symbol = 0;
        for symbol in s.chars().rev() {
            let value = match symbol {
                'I' => 1,
                'V' => 5,
                'X' => 10,
                'L' => 50,
                'C' => 100,
                'D' => 500,
                'M' => 1000,
                _ => panic!(),
            };

            if value >= highest_symbol {
                highest_symbol = value;
                result += value;
            }
            else{ result -= value; }
        }
        result
    }
}
