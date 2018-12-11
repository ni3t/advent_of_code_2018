require 'pp'

f = File.read('/Users/nbell/dev/advent2018/problems/10/input.txt').split("\n")

Struct.new("Star", :x,:y,:xv,:yv)
@stars = []

f.each do |line|
  @stars << Struct::Star.new(line[10..15].to_i,line[18..23].to_i,line[36..37].to_i, line[40..41].to_i)
end

@stars = @stars.map do |s| 
  Struct::Star.new(s.x + (10633 * s.xv),s.y + (10633*s.yv),s.xv,s.yv)
end

(10633..10633).each_with_index do |i,j|
  @stars = @stars.map do |s| 
    Struct::Star.new(s.x + s.xv,s.y + s.yv,s.xv,s.yv)
  end
  @arr = Array.new(50) { Array.new(100) {"."}}
  @stars.each do |star|
    @arr[star.y - 100][star.x-150] = "X"
  end
  puts @arr.map{|r| r.join("")}.join("\n")
end
