def map_string(string)
  case string
  when "one" then 1
  when "two" then 2
  when "three" then 3
  when "four" then 4
  when "five" then 5
  when "six" then 6
  when "seven" then 7
  when "eight" then 8
  when "nine" then 9
  else
    string.to_i
  end
end

REGEX = /[0-9]/
REGEX2 = /[0-9]|one|two|three|four|five|six|seven|eight|nine/

pp File
  .readlines("first.txt")
  # .readlines("example.txt")
  .map(&:strip)
  .map{|s|
    first = s.match(/^.*?(#{REGEX2})/)
    last = s.match(/.*(#{REGEX2}).*?\Z/)
    [map_string(first[1]), map_string(last[1])].join.to_i
  }
.sum


