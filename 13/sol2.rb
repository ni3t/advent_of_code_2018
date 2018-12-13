require 'set'

DIR = {
  ?^ => [-1, 0],
  ?v => [1, 0],
  ?< => [0, -1],
  ?> => [0, 1],
}.each_value(&:freeze).freeze

def falling_curve((y, x))
  [x, y].freeze
end

%w(>v <^).each { |pair|
  [pair.chars, pair.chars.reverse].each { |a, b|
    got = falling_curve(DIR[a])
    want = DIR[b]
    raise "falling_curve #{a} #{DIR[a]}: want #{want}, got #{got}" if got != want
  }
}

def rising_curve((y, x))
  [-x, -y].freeze
end

%w(>^ <v).each { |pair|
  [pair.chars, pair.chars.reverse].each { |a, b|
    got = rising_curve(DIR[a])
    want = DIR[b]
    raise "rising_curve #{a} #{DIR[a]}: want #{want}, got #{got}" if got != want
  }
}

def turn_left((y, x))
  [-x, y].freeze
end

'^<v>^'.each_char.each_cons(2) { |a, b|
  got = turn_left(DIR[a])
  want = DIR[b]
  raise "turn_left #{a} #{DIR[a]}: want #{want}, got #{got}" if got != want
}

def turn_right((y, x))
  [x, -y].freeze
end

'^>v<^'.each_char.each_cons(2) { |a, b|
  got = turn_right(DIR[a])
  want = DIR[b]
  raise "turn_right #{a} #{DIR[a]}: want #{want}, got #{got}" if got != want
}

def turn_intersection(dir, times)
  case times % 3
  when 1; turn_left(dir)
  when 2; dir
  when 0; turn_right(dir)
  else raise "math is broken for #{times}"
  end
end

Cart = Struct.new(:pos, :dir, :intersections, :dead) do
  def move!
    self.pos = pos.zip(dir).map(&:sum).freeze
  end
end

track=File.read(File.dirname(__FILE__)+ '/input.txt').each_line.map { |l|
  l.chomp.freeze
}.freeze

carts = track.each_with_index.flat_map { |row, y|
  row.each_char.with_index.map { |c, x|
    if (dir = DIR[c])
      Cart.new([y, x].freeze, dir.freeze, 0, false)
    end
  }.compact
}

first_crash = true

occupied = carts.map { |cart| [cart.pos, cart] }.to_h

until carts.size <= 1
  carts.sort_by!(&:pos)
  carts.each { |cart|
    # A lower-ID cart moved into this cart's current position
    next if cart.dead

    occupied.delete(cart.pos)

    if (crashed = occupied.delete(cart.move!))
      puts "Crash at #{cart.pos}"
      if first_crash
        puts cart.pos.reverse.join(?,)
        first_crash = false
      end
      cart.dead = true
      crashed.dead = true
      next
    end

    occupied[cart.pos] = cart

    cart.dir = case track[cart.pos[0]][cart.pos[1]]
    when ?\\; falling_curve(cart.dir)
    when ?/;  rising_curve(cart.dir)
    when ?+;  turn_intersection(cart.dir, cart.intersections += 1)
    else cart.dir
    end
  }

  carts.reject!(&:dead)
end

raise 'No carts left???' if carts.empty?
puts carts[0].pos.reverse.join(?,)