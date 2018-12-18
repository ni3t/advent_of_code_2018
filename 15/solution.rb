require 'pp'
f = File.read(File.dirname(__FILE__) + "/input.txt")
# f = <<-EOS
# #######
# #.G.E.#
# #E.G.E#
# #.G.E.#
# #######
# EOS

@verbose = ARGV.include? "-v"
# puts @verbose

def ppp arg
  if @verbose
    puts arg
  end
end

ppp "Verbose on"

# f = <<-EOS
# #######
# #E..G.#
# #...#.#
# #.G.#G#
# #######
# EOS

# f = <<-EOS
# #########
# #G..G..G#
# #.......#
# #.......#
# #G..E..G#
# #.......#
# #.......#
# #G..G..G#
# #########
# EOS

# # f = <<-EOS
# # #########
# # #G..G..G#
# # #.......#
# # #.......#
# # #...E...#
# # #.......#
# # #.......#
# # #.......#
# # #########
# # EOS

# f = <<-EOS
# #######
# #.G...#
# #...EG#
# #.#.#G#
# #..G#E#
# #.....#
# #######
# EOS

# f = <<-EOS
# #######
# #G..#E#
# #E#E.E#
# #G.##.#
# #...#E#
# #...E.#
# #######
# EOS

# f = <<-EOS
# #######
# #E..EG#
# #.#G.E#
# #E.##E#
# #G..#.#
# #..E#.#
# #######
# EOS

# f = <<-EOS
# #######
# #E.G#.#
# #.#G..#
# #G.#.G#
# #G..#.#
# #...E.#
# #######
# EOS

# f = <<-EOS
# #######
# #.E...#
# #.#..G#
# #.###.#
# #E#G#G#
# #...#G#
# #######
# EOS
f= <<-EOS
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
EOS
NEIGHBOR_LOOKS=[
  [1,0],
  [0,1],
  [0,-1],
  [-1,0]
].freeze

Cell = Struct.new(:x,:y,:occupant){
  def neighbors(reject=nil)
    NEIGHBOR_LOOKS.map{|l|
      begin
        cell = [self.x-l[1],self.y-l[0]] 
        GRID[cell[1]][cell[0]]
      rescue => exception
        nil        
      end
    }.compact.reject{|n| n==reject || !n.travelable}
  end
  def travelable
    self.occupant.name != 'Wall'
  end
}

Unit = Struct.new(:name,:id,:hp,:moved_this_round){
  def attack(cell)
    return if !['Elf','Goblin'].include?(self.name)
    opponent = nil
    if self.name == 'Elf'
      opponent = 'Goblin'
    else
      opponent = 'Elf'
    end
    target = cell.neighbors.select{|n| n.occupant.name == opponent}.sort_by{|n|n.occupant.hp}.first
    if target && self.hp > 0
      target.occupant.hp = target.occupant.hp - 3
    end
  end
  def calculate_move(cell)
    return if !['Elf','Goblin'].include?(self.name)
    return if self.moved_this_round
    opponent = nil
    if self.name == 'Elf'
      opponent = 'Goblin'
    else
      opponent = 'Elf'
    end
    return if cell.neighbors.map(&:occupant).map(&:name).include? opponent

    # ppp "neighbors in order: #{cell.neighbors.map{|c| "#{c.x},#{c.y}"}}"

    @paths = [[cell]]
    @traveled = [cell]
    @exit = false
    until @exit || @paths.map(&:last).map(&:occupant).map(&:name).include?(opponent)
      @new_paths = []
      @paths.map{|path|
        path.last.neighbors.map{|neighbor|
          new_path = ([] << path).flatten
          # puts "checking neighbor #{neighbor.x},#{neighbor.y} for #{path.last.x},#{path.last.y}"
          if path.include? neighbor
            # puts "skipping, in path"
            next
          end
          if !neighbor.travelable
            # puts "skipping, wall"
            next
          end
          if @new_paths.map(&:last).include? neighbor
            # puts "skipping, covered"
            next
          end
          if @traveled.include? neighbor
            # puts "skipping, traveled."
            next
          end
          if neighbor.occupant.name == self.name
            next
          end
          # ppp "adding" if @verbose
          @traveled << neighbor
          new_path << neighbor
          @new_paths << new_path
        }
      }
      # puts "***"
      # pp @new_paths.map{|p| p.map{|step| "#{step.x},#{step.y}"}}
      if @new_paths.empty?
        @exit = true
      else
        @paths = @new_paths
      end
    end
    if @paths && @paths.map(&:last).map(&:occupant).map(&:name).include?(opponent)
      target = GRID.flatten.select do |c|
        c.occupant.name == opponent &&
        @paths.map(&:last).include?(c)
      end.first
      next_step = @paths.select{|p| p.last == target && p.last.occupant.name != self.name}.first[1]
      # pp next_step
  
      temp = GRID[next_step.y][next_step.x].occupant
      curr = GRID[cell.y][cell.x].occupant
      if temp.name == 'Empty'
        curr.moved_this_round = true
        GRID[next_step.y][next_step.x].occupant = curr
        GRID[cell.y][cell.x].occupant = temp 
      end
    end
    # print_grid
    # sleep 0.5
  end

}

f=f.each_line.map(&:chomp).map{|line| line.split("")}

next_elf = 1.step
next_gob = 1.step

GRID=f.map.with_index{|l,y| l.map.with_index{|c,x| 
  case c
  when "#"
    Cell.new(x,y,Unit.new("Wall"))
  when "."
    Cell.new(x,y,Unit.new("Empty"))
  when "E"
    Cell.new(x,y,Unit.new("Elf", next_elf.next, 200))
  when "G"
    Cell.new(x,y,Unit.new("Goblin", next_gob.next, 200))
  else
    throw "Shit"
  end
}}

def print_grid
  puts GRID.map{|row| 
    row.map{|col| 
      case col.occupant.name
      when "Wall"
        "#"
      when "Goblin"
        "G"
      when 'Elf'
        'E'
      when 'Empty'
        '.'
      else
        raise "Hell"
      end
      }.join("") + 
      "  " + 
      row.select{|col| ['Elf','Goblin'].include? col.occupant.name}
      .map{|c| "(#{c.occupant.name.chars.first} #{c.occupant.id} #{c.occupant.hp} )"}.join(" ")
    }.join("\n") + "\n\n" + "     round #{@round.next}\n" + "*"*25 + "\n\n"
end

def clean_grid
  GRID.flatten.map do |cell|
    if cell.occupant.name == 'Elf' || cell.occupant.name == 'Goblin'
      if cell.occupant.hp <= 0
        cell.occupant.name = "Empty"
        cell.occupant.hp = nil
        cell.occupant.id = nil
      end
    end
  end
end

def check_if_over
  GRID.flatten.map{|cell| cell.occupant.name}.uniq.length < 4
end

def get_hp
  GRID.flatten.map{|cell| cell.occupant.hp}.compact.sum
end

@round = 1.step

def take_a_turn
  print_grid
  GRID.flatten.map{|c| 
    c.occupant.moved_this_round = false
  }
  GRID.flatten.map{|c| 
    clean_grid
    c.occupant.calculate_move(c)
    c.occupant.attack(c)
  }
  if check_if_over
    round = @round.next - 2
    puts "Finished after #{round} rounds."
    puts "HP remaining = #{get_hp}"
    puts "answer: #{round * get_hp}"
    exit
  end
  sleep 0.1
end

loop do
  take_a_turn
end

