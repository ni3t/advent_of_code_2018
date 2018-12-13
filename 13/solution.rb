require 'pp'
f=File.read(File.dirname(__FILE__) + "/input.txt")
# f=File.read(File.dirname(__FILE__) + "/test.txt")
f=f.each_line.map(&:chomp)
ARROWS = [?^,?>,?v,?<]
LOOKS = [[0,-1],[1,0],[0,1],[-1,0]]
PAIRS = ARROWS.zip(LOOKS).to_h

LEFT = "^<v>^".chars.each_cons(2).to_a
RIGHT = LEFT.map(&:reverse)
TURNS = ['\\',?/]
ACTIONS = LEFT.zip(RIGHT).flatten.each_slice(4).to_a
  .zip(TURNS.cycle).map(&:reverse).each_slice(2).map(&:to_h)
  .each_with_object({}){|r,h| r.map{|k,v| h[k] ? h[k].concat(v.each_slice(2).to_a) : h[k] = v.each_slice(2).to_a};h}

verbose =false
Struct.new("Grid", :grid)

Struct.new("Cart", :pos, :dir, :turns, :grid, :prev_pos, :prev_dir, :prev_tile,:tile) {
  def move
    self.prev_pos = self.pos if self.pos
    self.prev_dir = self.dir if self.dir
    self.prev_tile = self.tile if self.tile
    self.pos = self.pos.zip(PAIRS[self.dir]).map(&:sum)
    self
  end
  def set_new_dir
    self.tile = self.grid[self.pos[1]][self.pos[0]]
    self.dir = ACTIONS[self.tile]&.select{|a| a[0]==self.dir}&[1] || self.tile
    self.tile == ?+ && self.dir = ARROWS[ARROWS.rotate(1 - (self.turns % 3)).index(self.dir)] && self.turns += 1
    self
  end
}

@carts = []

grid = f.each_with_index.map do |row,i|
  row.chars.each_with_index.map do |cell,j|
    idx = ARROWS.index(cell)
    @carts << Struct::Cart.new([j,i],cell,0,nil,[j,i],cell,(ARROWS.index(cell).odd? ? "-" : "|"),(ARROWS.index(cell).odd? ? "-" : "|")) if idx
    idx ? idx.even? ? '|' : '-' : cell
  end
end


@carts.map{|c| c.grid = grid}


puts "@carts count #{@carts.count}"

def print_grid
  @carts.map do |c|
    grid[c.pos[1]][c.pos[0]] = "&"
    grid[c.prev_pos[1]][c.prev_pos[0]] = c.prev_tile
  end
  puts grid.map{|r| r.join}.join("\n")
  puts "\n\n"
  sleep 0.01
end

@crash = 1
until @carts.count < 2
  print_grid if verbose
  if @carts.map(&:move).map(&:set_new_dir).map(&:pos).uniq.count != @carts.count
    @position = []
    @carts.map(&:pos).uniq.map do |p|
      crashed_carts = @carts.select{|c| c.pos == p}
      if crashed_carts.count > 1
        @position = crashed_carts.first.pos
        crashed_carts.each do |cart|
          idx = @carts.index(cart)
          print_grid if verbose
          @carts.delete_at(idx)
        end
      end
    end
    puts "crash #{@crash} = #{@position}"

    @crash += 1
  end
end


pp @carts.first&.pos