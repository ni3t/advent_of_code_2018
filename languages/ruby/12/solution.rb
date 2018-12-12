# 695/405

require 'pp'
f = File.read('/Users/nbell/dev/advent2018/problems/12/input.txt').split("\n")

FILLER_STRING = ".........."


INIT = '....#.#.#....##...##...##...#.##.#.###...#.##...#....#.#...#.##.........#.#...#..##.#.....#..#.###....'+FILLER_STRING+FILLER_STRING+FILLER_STRING+FILLER_STRING
mapped = f.map{|r|r.match(/(.*) => (.)/)}.map{|m| {pattern: m[1], next: m[2]}}

@next = INIT.chars
@res = 0
(1..20).map do |round|
  @last = @next
  @next = @last.each_with_index.map do |pot,i|
    five = @last[i-2..i+2].join("")
    next_pos = mapped.select{|m| m[:pattern] == five}
    !next_pos.empty? ? next_pos[0][:next] : "."
  end
  @next.push(".").join()
  
  res = @next.each_with_index.map{|r,i| r == "#" ? i : 0 }.inject(&:+)
  puts "#{round} - #{res}"
  @res = res
  @next
end

puts @res

pp (5e10 - 500) * 20 + 10588