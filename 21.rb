# depth: 7305
# target: 13,734

VERBOSE = ARGV.delete("-v")
DEPTH = ARGV[0]&.to_i || 7305
TX = ARGV[1]&.to_i || 13
TY = ARGV[2]&.to_i|| 734

(puts "Depth #{DEPTH}, Target: (#{TX},#{TY})") if VERBOSE

Region = Struct.new(:x,:y,:target,:geo_index,:time_to_reach) {
  def set_geo_index
    case [x,y].sum
    when 0; self.geo_index = 0
    when x; self.geo_index = x * 16807
    when y; self.geo_index = y * 48271
    else self.geo_index = CAVE[y-1][x].erosion_level * CAVE[y][x-1].erosion_level
    end
  end
  def erosion_level
    (DEPTH + self.geo_index) % 20183
  end
  def risk_level
    target ? 0 : erosion_level % 3
  end
  def type
    %w(. = |)[risk_level]
  end
  def type_txt
    %w(Rocky Wet Narrow)[risk_level]
  end
  def display
    (time_to_reach&.to_s || type&.to_s).rjust(3," ")
  end
}

CAVE = Array.new(TY+20){|i| Array.new(TX+20){|j| Region.new(j,i,false)}}
# starting at y = 0, x = whatever, and moving southwest, set the geo index. go until all are filled.
(0..[TY,TX].sum+200).to_a.permutation(2).to_a.concat((0..[TY,TX].sum+200).map{|i|[i,i]})
  .group_by{|pair| pair.sum}.map{|group| group[1].sort_by{|pair| pair.first}}
  .flatten(1).map do |pair|
    y,x = pair
    next if y >= CAVE.length || x >= CAVE.first.length
    CAVE[y][x].set_geo_index
  end
  
CAVE[TY][TX].target = true


def part_1
  CAVE[0..TY].map do |row|
    row[0..TX].map(&:risk_level).sum
  end.sum
end

puts part_1


Spawn = Struct.new(:x,:y,:tool,:spawn_wait,:dead,:new) {
  def neighbors
    [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]
      .reject{|pair| pair.any?{|e| e < 0}}
      .reject{|x,y| y >= CAVE.length || x >= CAVE.first.length}
      .map{|x,y| CAVE[y][x]}
  end
  def found_friend
    if self.x == TX && self.y == TY
      if self.tool == 1
        if self.spawn_wait == 0
          return true
        else
          self.spawn_wait -= 1
        end
      else
        self.tool = 1
        self.spawn_wait = 6
      end
    end
  end
  def travel
    if self.new
      self.new = false
      return
    end
    if self.spawn_wait > 0
      # puts "#{self.x},#{self.y} is waiting..."
      self.spawn_wait -= 1
      return
    end
    # puts "#{self.x},#{self.y} traveling now."
    CAVE[y][x].time_to_reach = GAME.time
    travelable = neighbors.select{|n| n.time_to_reach == nil}
    case travelable.count
    when 0; self.dead = true
    when 1
      c = travelable.shift
      if c.risk_level == tool
        self.dead = true
        too = [0,1,2]
        too.delete_at(tool)
        GAME.travelers << Spawn.new(self.x,self.y,too[0],7,false,true)
        GAME.travelers << Spawn.new(self.x,self.y,too[1],7,false,true)
      else
        self.x,self.y = c.x,c.y
      end
    when 2,3
      # puts "#{self.x},#{self.y} splitting since #{travelable.count} to go to"
      travelable.each do |c|
        if c.risk_level == tool
          # puts "found an incompatible point (#{c.x},#{c.y}). splitting and waiting."
          self.dead = true
          too = [0,1,2]
          too.delete_at(tool)
          GAME.travelers << Spawn.new(self.x,self.y,too[0],6,false,true)
          GAME.travelers << Spawn.new(self.x,self.y,too[1],6,false,true)
        else
          self.dead = true
          # puts "going to next (#{c.x},#{c.y})"
          GAME.travelers << Spawn.new(c.x,c.y,tool,0,false,true)
        end
      end
    else
      raise "wtf just happened"
    end
  end
}

Game = Struct.new(:time,:travelers)
ORIGIN = CAVE[0][0]
travs = [Spawn.new(ORIGIN.x, ORIGIN.y, 1, 0)]

GAME = Game.new(0,travs)

TOOLS = %w(neither torch climb)

until GAME.time == 1200 
  # puts "I have #{GAME.travelers.count} player(s) at time #{GAME.time}, positions #{GAME.travelers.map{|t| [t.x,t.y,t.tool,t.spawn_wait]}}"
  trav_to_add = GAME.travelers.map(&:travel)
  GAME.travelers = GAME.travelers.uniq
  GAME.travelers.delete_if{|t| t.dead}
  if GAME.travelers.any?{|t| t.found_friend}
    puts "#{GAME.time}"
    break
  end
  GAME.time += 1 
  # map = CAVE.map do |row|
  #   row.map do |region|
  #     region.display
  #   end.join
  # end.join("\n")
  # puts map
  # puts "-"*25
end