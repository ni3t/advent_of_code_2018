require 'pp'

f = File.read(File.dirname(__FILE__) + "/input.txt").split("\n")

f = <<-EOS
x=490, y=1..7
y=7, x=490..501
x=501, y=2..7
x=498, y=3..5
x=496, y=3..5
y=5, x=496..498
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
EOS
f=f.split("\n")

lines = f.map do |line|
  fdir,fnum = line.split(",")[0].split("=")
  sdir,snum = line.split(",")[1].split("=")
  snum = (snum.split("..")[0].to_i..snum.split("..")[1].to_i)
  if fdir == ?x
    {x: fnum.to_i,y:snum}
  else
    {y: fnum.to_i,x:snum}
  end
end


@global_max_x = lines.map{|line| line[:x].class == Integer ? line[:x] : line[:x].to_a.max }.max
@global_min_x = lines.map{|line| line[:x].class == Integer ? line[:x] : line[:x].to_a.max }.min
@global_max_y = lines.map{|line| line[:y].class == Integer ? line[:y] : line[:y].to_a.max }.max
@global_min_y = lines.map{|line| line[:y].class == Integer ? line[:y] : line[:y].to_a.max }.min

Cell = Struct.new(:x,:y,:occupant){
  def str
    case occupant
    when 'Clay'; "#"
    when 'Source'; "+"
    when 'Water'; "~"
    when 'Stream'; "|"
    else "."
    end
  end

  def my_row
    if !GRID[y+1]
      return []
    end
    below = GRID[y+1][x].occupant
    @row = []
    if ['Clay','Water'].include? below
      @x = x
      @op = :+
      until @op == false 
        if @x > GRID[0].length - 2
          @op = :-
          next
        elsif @x < 0
          @op = false
          next
        else
          if GRID[y+1][@x].occupant.nil? || GRID[y][@x].occupant == 'Clay'
            if @op == :+
              @op = :-
              @x = @x.send(@op,1)
            else
              @op = false
            end
          else
            @row << GRID[y][@x]
            @x = @x.send(@op,1)
          end
        end
      end
    end
    @row = @row.uniq.sort_by{|cell|cell.x}
    @row
  end

  def overflows?
    if !my_row.empty?
      pp my_row
      first = my_row.first
      last = my_row.last
      occs = [GRID[y][first.x - 1],GRID[y][last.x + 1]].map(&:occupant)
      res = occs.include?(nil) || occs.include?("Source")
      my_row.map{|cell| cell.occupant = "Stream"}
      res
    else
      false
    end
  end

  def fill_overflow
    row = my_row.select{|cell| !GRID[cell.y+1][cell.x].occupant.nil?}
    minmax = row.minmax_by(&:x)
    left = GRID[y][minmax[0].x-1]
    right = GRID[y][minmax[1].x+1]
    row.map{|cell| cell.occupant = "Stream"}
    [left,right].map{|cell| cell.occupant.nil? && cell.occupant = "Source"}
    [left,right]
  end
}

GRID = Array.new(@global_max_y+2) {|y| Array.new(@global_max_x+10) {|x| Cell.new(x,y,nil)}}

GRID[0][500] = Cell.new(500,0,"Source")

lines.map do |line|
  if line[:x].class == Integer
    line[:y].to_a.each do |i|
      GRID[i][line[:x]] = Cell.new(line[:x],i,"Clay")
    end
  else
    line[:x].to_a.each do |i|
      GRID[line[:y]][i] = Cell.new(i,line[:y],"Clay")
    end
  end
end

def print_grid
  puts "*"*25 + "\n\n"
  res = GRID[@global_min_y-2..@global_max_y].map{|r| r[@global_min_x-5..@global_max_x].map(&:str).join}.join("\n")
  puts res
  res
end

def drip(source, sources)
  @cur = source
  @y = @cur.y + 1
  @cur = GRID[@y][@cur.x]
  until @cur.occupant == "Water" || @cur.occupant == 'Clay' || @y == GRID.length
    @cur.occupant = "Stream"
    if GRID[@y] && GRID[@y][@cur.x]
      @cur = GRID[@y][@cur.x]
      @y += 1
    else
      @break=true
    end
  end
  @bottom = GRID[@cur.y - 1][@cur.x]
  @bottom.occupant = "Stream"
  until @bottom.overflows? || @bottom.y == GRID.length || @bottom.occupant == "Source"
    @bottom.my_row.map{|cell| cell.occupant = "Water"}
    @bottom = GRID[@bottom.y - 1][@bottom.x]
  end
  if @bottom.y == GRID.length
    source.occupant = "Stream"
  elsif @bottom == source
    source.occupant = 'Stream'
  else
    @bottom.fill_overflow
    source.occupant = "Stream"
  end
  sources = GRID.flatten.select{|cell| cell.occupant == 'Source'}
  print_grid
  sources

end

def loopback
  @sources = [GRID[0][500]]
  until @sources.length == 0
    @sources.map{|source| @sources = drip(source,@sources)}
  end
end

loopback

puts GRID.flatten.select{|cell| ['Water','Stream'].include?(cell.occupant)}.count - 1

print_grid