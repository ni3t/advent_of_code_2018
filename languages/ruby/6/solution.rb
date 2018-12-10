require 'pp'
@pts = File.read('/Users/nbell/dev/advent2018/problems/6/input.txt').split("\n").map { |r| r.split(',').map(&:to_i) }

# given a point A with coordinates x1:y1 on a coordinate plane,
# where x increases easterly and y increases southerly
# if there is another point B with coordinates x2:y2,
# the positioning of the two can be in one of sixteen combinations, abbreviated with 3-letter compass names ("SE", "WSW", etc)
# each point takes all other points into account in determining whether it is occluded.
# For each point, if there is at least one other point that occludes each of its 16 directions, it is a "surrounded" point.
# Certain directional combinations also include others.
# Cardinal Directions (N for example) and Corner Directions (NE)
# occlude two adjacent in each direction, from NW-NNW-N-NNE-NE or N-NNE-NE-ENE-E
# Tertiary directions only occlude themselves.
# A cardinal directional relationship occurs when two points share an X or Y value
# A corner directional relationship occurs when |x1-x2| == |y1-y2|

@infs = []
all_dirs = %w[E ENE NE NNE N NNW NW WNW W WSW SW SSW S SSE SE ESE]

def rel(p1, p2)
  return %w[W WNW NW NNW N] if (p1[0]-p2[0])==(p1[1]-p2[1]) && p1[0] > p2[0]
  return %w[E ENE NE NNE N] if (p2[0]-p1[0])==(p1[1]-p2[1]) && p1[0] > p2[0]
  return %w[W WSW SW SSW S] if (p2[0]-p1[0])==(p1[1]-p2[1]) && p1[0] < p2[0]
  return %w[E ESE SE SSE S] if (p1[0]-p2[0])==(p1[1]-p2[1]) && p1[0] < p2[0]
  return %w[NE NNE N NNW NW] if p2[1] < p1[1] && ((p2[0]-p1[0]).abs < (p2[1]-p1[1]).abs)
  return %w[SE SSE S SSW SW] if p2[1] > p1[1] && ((p2[0]-p1[0]).abs > (p2[1]-p1[1]).abs)
  return %w[NE ENE E ESE SE] if p2[0] > p1[0] && ((p2[0]-p1[0]).abs > (p2[1]-p1[1]).abs)
  return %w[NW WNW W WSW SW] if p2[0] < p1[0] && ((p2[0]-p1[0]).abs < (p2[1]-p1[1]).abs)
  return ["OOPS"]
end

@pts.each do |p1|
  dirs = []
  (@pts - [p1]).each do |p2|
    dirs.concat(rel(p1,p2))
  end
  if dirs.uniq.count != 17
    @infs << p1
  end
end

# pp points - infs

# the "manhattan distance" between two points is |x2-x1| + |y2-y1|

def manhattan_distance(p1,p2)
  (p2[0]-p1[0]).abs + (p2[1]-p1[1]).abs
end
@points = @pts - @infs

@points = @points.each_with_index.map do |xy,i|
  {mark: ("A".."Z").to_a[i], coords: xy}
end

@infs = @infs.each_with_index.map do |xy,i|
  {mark: ("a".."z").to_a[i], coords: xy}
end

@finals = @points + @infs

def closest_coordinate point
  if ->minpt{@finals.select{|pt| manhattan_distance(minpt[:coords],point) == manhattan_distance(pt[:coords],point)}.count}.call(@finals.min_by{|pt| manhattan_distance(pt[:coords], point)}) != 1
    "." 
  else
    @finals.min_by{|pt| manhattan_distance(pt[:coords], point)}[:mark]
  end 
end

@a = Array.new(375){ |row| Array.new(375) {|col| "."}}



@a = @a.each_with_index.map do |row,i|
  row.each_with_index.map do |pt,j|
    closest_coordinate([i,j])
  end
end


puts @a.map{|row| row.join("")}.join("\n")
puts->h{@a.flatten.count(h[:mark])}.call(@points.max_by{|pt| @a.flatten.count(pt[:mark])})
puts @a.flatten.count("t")

#part 2
part_two = @a.each_with_index.map do |row,i|
  row.each_with_index.map do |col,j|
    @pts.map do |pt2|
      manhattan_distance([i,j],pt2)
    end.inject(&:+)
  end
end.flatten.select{|d| d < 10000}.count
puts part_two