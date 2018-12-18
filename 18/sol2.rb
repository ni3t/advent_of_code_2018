require 'time'

# Nothing ever depends on the count of OPEN,
# so we are safe to make OPEN 0.
# Otherwise, we'd have to number elements 1, 2, 3.
# Not that it matters anyway; either way, space is being wasted.
# (two bits can represent four elements, but we only have three)
OPEN = 0
TREE = 1
LUMBER = 2

# 2 bits per cell, 9 cells in 3x3 neighbourhood,
# arranged in this way:
# [top left,  top, top right]
# [left    , self, right]
# [bot left,  bot, bot right]
# Move across the array while keeping three bit patterns,
# one for each row, masking off the left as we go.
# We compress the entire thing into an 18-bit integer
# and index into a lookup table.

BITS_PER_CELL = 2
CELLS_PER_ROW = 3
CELL_MASK = (1 << BITS_PER_CELL) - 1
ROW_MASK = (1 << (BITS_PER_CELL * CELLS_PER_ROW)) - 1
MID_OFFSET = BITS_PER_CELL * CELLS_PER_ROW
TOP_OFFSET = BITS_PER_CELL * CELLS_PER_ROW * 2

# Note that the current cell (the one whose next state is being considered)
# is index 4 here
ME = 4
NOT_ME = (0...9).to_a - [ME]

verbose = ARGV.delete('-v')

before_lookup = Time.now

# It takes about half a second to build the lookup table,
# but the time it saves makes it worth it!
NEXT_STATE = (1 << 18).times.map { |i|
  trees = 0
  lumber = 0
  NOT_ME.each { |j|
    n = (i >> (j * BITS_PER_CELL)) & CELL_MASK
    if n == TREE
      trees += 1
    elsif n == LUMBER
      lumber += 1
    end
  }
  case (i >> (ME * BITS_PER_CELL)) & CELL_MASK
  when OPEN
    trees >= 3 ? TREE : OPEN
  when TREE
    lumber >= 3 ? LUMBER : TREE
  when LUMBER
    lumber > 0 && trees > 0 ? LUMBER : OPEN
  else
    # Note that 3 is unfortunately a waste of space.
  end
}.freeze

puts "Lookup table in #{Time.now - before_lookup}" if verbose

# Next state resulting from `src` is written into `dest`
def iterate(src, dest)
  dest.each_with_index { |write_row, y|
    top = y == 0 ? nil : src[y - 1]
    mid = src[y]
    bot = src[y + 1]

    top_bits = top ? top[0] : 0
    mid_bits = mid[0]
    bot_bits = bot ? bot[0] : 0

    (1...write_row.size).each { |right_of_write|
      top_bits = ((top_bits << BITS_PER_CELL) & ROW_MASK) | top[right_of_write] if top
      mid_bits = ((mid_bits << BITS_PER_CELL) & ROW_MASK) | mid[right_of_write]
      bot_bits = ((bot_bits << BITS_PER_CELL) & ROW_MASK) | bot[right_of_write] if bot
      write_row[right_of_write - 1] = NEXT_STATE[(top_bits << TOP_OFFSET) | (mid_bits << MID_OFFSET) | bot_bits]
    }

    # The last element in the row (which has no elements to its right)
    top_bits = (top_bits << BITS_PER_CELL) & ROW_MASK
    mid_bits = (mid_bits << BITS_PER_CELL) & ROW_MASK
    bot_bits = (bot_bits << BITS_PER_CELL) & ROW_MASK
    write_row[-1] = NEXT_STATE[(top_bits << TOP_OFFSET) | (mid_bits << MID_OFFSET) | bot_bits]
  }
end

def compress(grid)
  # grid.flatten *does* work, of course,
  # but let's see if we can do better.
  grid.map { |r| r.reduce(0) { |acc, cell| (acc << BITS_PER_CELL) | cell } }
end

TESTDATA = <<SAMPLE
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
SAMPLE

print_grid = ARGV.delete('-g')
current = (ARGV.include?('-t') ? TESTDATA : ARGV.empty? ? DATA : ARGF).each_line.map { |l|
  l.chomp.each_char.map { |c|
    case c
    when ?.; OPEN
    when ?|; TREE
    when ?#; LUMBER
    else raise "invalid #{c}"
    end
  }
}

def resources(grid, verbose)
  flat = grid.flatten
  trees = flat.count(TREE)
  lumber = flat.count(LUMBER)
  "#{"#{trees} * #{lumber} = " if verbose}#{trees * lumber}"
end

patterns = {}

buffer = current.map { |row| [nil] * row.size }

1.step { |t|
  iterate(current, buffer)
  current, buffer = buffer, current

  puts resources(current, verbose) if t == 10

  key = compress(current)

  if (prev = patterns[key])
    cycle_len = t - prev

    # If we stored in `patterns` in a reasonable way,
    # we could just look in `patterns`...
    # instead we'll just iterate more.
    more = (1000000000 - t) % cycle_len
    previous = t + more - cycle_len
    #prev_flat = patterns.reverse_each.find { |k, v| v == previous }[0]

    puts "t=#{t} repeats t=#{prev}. #{more} more cycles needed (or rewind to #{previous})" if verbose

    more.times {
      iterate(current, buffer)
      current, buffer = buffer, current
    }

    puts resources(current, verbose)

    break
  end

  patterns[key] = t
}

current.each { |row|
  puts row.map { |cell|
    case cell
    when OPEN; ?.
    when TREE; ?|
    when LUMBER; ?#
    else raise "Unknown #{cell}"
    end
  }.join
} if print_grid

__END__
....#......|.#........###|...||.#|||.||.|...|.#.|.
|#|#....|#...||.|#.#|.|.|..#...||.#|#.|.#||#||.|#.
.....##...#..###..##.|.|....|..#.|...#.#.....|.|..
|....#|||#..||##....||#||.|..|...|..#....#|#....|#
|......|......|.#...|.....|..|.#...#.#..#|.....#|.
|#...#....#...#.|..#..|...|#..|.#.......#..#....|#
....|#.|#...........##...||......##...||#...#..|.|
.#.....|..|...|#..##||..#.#...#...#|.#...#.|....#.
.##|.....|||.....||.#...#...#...#......##...||#...
.||#.|#..|.....#.|.|..........|.#..|##...||...|#..
|......|..#...#.##||..||..#.|..|.|....##|..|..|.|.
|#...####.#.|.....|#..#....|#.#..|.#.#|####.#..|..
.#|.....#.|....|###..#||...#|...||.|.#|#.....|##..
#.|..#|..#...||#.#|...#.##|..|..#...|#.....|..#|..
#.|.....##..||##....|..|.|.|..##.#..|||.....|.....
......##|..|#.|#||...#.|..#..|.#....|..#....#..|##
|........|#.#.|.##...#|..|##.....|##.|.#....#.#...
#.#..#..|.........#|.##.......|...|.#..#.#|####.#.
.....#||#..|......#|.....#..|||..##.......#.#..#.#
#...........#|..#..|.||.|||.|....#||....|#..##.#..
.|...#..##|#...#.||.|##.|..#.||.#.#.#.###...#...#|
|#|...|.......#..#..#....|.###..|.||...|.#...|....
..#.#......|..|.||#.||.......|..#|.#.|..|.#..#.#.#
#..#...|...|..|..#....|..|...|#|...#......#...#...
|...|.|.||#...|...|....|...#.|.#.|.|.|#..|..###.#.
..|.|.....|##...##....|..|.....||...#..||##......|
.#.#....|.##|....|.|..|.|##..#...|##|.#.#.##|....#
..#|.|.....|.#....|...||....|.#..|#.#.|#|.||.||...
.|##.|.#|#|...|...##.||.....|.#|....|.....|#..||..
|.#|...||....#|..#...|.....|.....#|...|#.#|..|....
.|...|....###.|....||##||..|#||.#|##|..|.#.......|
...#.||###|#|.#.|...#...|.##.|.||#..#.......||.#.#
.#|....|#.|.###.##|...|#...#.||..##...#.#|##...#.#
..|#|#..#..#..#|#.....|.#.|...|..#.#......###..|.|
#.|.|..#.#.#.#.....|........|#.||..#......#|.....#
...#.#|#|.|.###|#...#.|......#|.......##||......#.
.#|#.|#..#|...|.|...##|.#....|#........|..|.#.#.#.
..|.##.|#..|...#|.#...#........|.|#|.#.|.|..|#|.#.
...#.#.#||.|||...|#||..##.....###......#..#|||#..#
...#.....#||##.|..#.#|......||..#..#..#..|..|..|..
####.|....|.......|.|.#...|...#.#.......|.|.#...||
..|.|#|.#..##..##...#.....|...|...#|.|...#|..#..##
|...##.#|.........#..||#..||.#....||#..|..||....#|
.#..........#|#.#|#.|...|#....|..|...|...##....|#.
|.|#..|..|......#..|...|..##|||#...|..##|...#.|#..
||#.||.#|.|...#.........#...|.|##.#.|#||.|.#|..#..
|..|..|..#....#...|.......#|.........|#....#|....|
##..###......#|.........|.......|...||.......#|..#
|..............#.......#...#|.|||..#..|..#........
...|||.#.|.#.|..#.....##|....###.#.|....|.......|.