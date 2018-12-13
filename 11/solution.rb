require 'pp'
input = 7511
@a1=Array.new(300){Array.new(300){nil}}.each_with_index.map do |row,i|
  row.each_with_index.map do |col,j|
    ((((((i+10)*j)+input)*(i+10)).to_s[-3]||0).to_i)-5
  end
end

def get_box_power(i,j)
  @a2[i..i+2].map{|r| r[j..j+2]}.flatten.inject(&:+)
end

# pp get_box_power(33,45)
# pp get_box_power(21,61)
@a3 = Array.new(298){Array.new(298){nil}}
  .each_with_index.map{|a,i|a.each_with_index.map{|b,j|get_box_power(i,j)}}

max = @a3.flatten.max
loc = @a3.flatten.index(max)
x = loc / 298
y = loc % 298
pp [x,y]

# res = (2..299).to_a.map do |k|
#   @afinal = Array.new(k){Array.new(k){nil}}.each_with_index.map{|a,i|a.each_with_index.map{|b,j|@a2[i..i+(300-k)].map{|r| r[j..j+(300-k)]}.flatten.inject(&:+)}}
#   max = @afinal.flatten.max
#   loc = @afinal.flatten.index(max)
#   x = loc / 298
#   y = loc % 298
#   pp [max,k,x,y]
#   [max,k,x,y]
# end

# res.max_by{|r| r[0]}


# puts test(122,79,57)
# puts test(217,196,39)
# puts test(101,153,71)

serial = @input

def power_level(x, y, serial)
  rack_id = x + 10
  level = ((rack_id * y) + serial) * rack_id
  level = (level / 100) % 10
  level - 5
end

def grid(serial)
  (1..300).map do |y|
    (1..300).map { |x| power_level(x, y, serial) }
  end
end

def biggest_square(width, grid)
  last_idx = 300 - (width - 1)
  squares = (1..last_idx).map do |y|
    (1..last_idx).map do |x|
      sum = grid[(y - 1)...(y - 1 + width)].
        map {|column| column[(x - 1)...(x - 1 + width)]}.
        flatten.inject(&:+)
      [x, y, sum]
    end
  end

  squares.flatten(1).max_by {|s| s[2]}
end

grid = grid(serial)
# puts biggest_square(3, grid)
puts (2..20).map { |n| biggest_square(n, grid) + [n] }.max_by {|s| s[2]}