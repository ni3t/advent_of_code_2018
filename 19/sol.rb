require 'pp'

V = ARGV.delete('-v')

TESTDATA = <<TEST.freeze
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
TEST

## taken from day 16

OP_MAP = {
  :gtri => ->(a,b,c,r){ r[c] = r[a] > b ? 1 : 0;r },
  :gtrr => ->(a,b,c,r){ r[c] = r[a] > r[b] ? 1 : 0;r },
  :eqri => ->(a,b,c,r){ r[c] = r[a] = b ? 1 : 0;r },
  :eqir => ->(a,b,c,r){ r[c] = a == r[b] ? 1 : 0;r },
  :eqrr => ->(a,b,c,r){ r[c] = r[a] == r[b] ? 1 : 0;r },
  :gtir => ->(a,b,c,r){ r[c] = a > r[b] ? 1 : 0;r },
  :banr => ->(a,b,c,r){ r[c] = r[a] & r[b];r },
  :setr => ->(a,b,c,r){ r[c] = r[a];r },
  :bani => ->(a,b,c,r){ r[c] = r[a] & b;r },
  :seti => ->(a,b,c,r){ r[c] = a;r },
  :addr => ->(a,b,c,r){ r[c] = r[a] + r[b];r },
  :mulr => ->(a,b,c,r){ r[c] = r[a] * r[b];r },
  :muli => ->(a,b,c,r){ r[c] = r[a] * b;r },
  :addi => ->(a,b,c,r){ r[c] = r[a] + b;r },
  :bori => ->(a,b,c,r){ r[c] = r[a] | b;r },
  :borr => ->(a,b,c,r){ r[c] = r[a] | r[b];r}
}.freeze

instr = (ARGV.include?('-t') ? TESTDATA : ARGV.empty? ? DATA : ARGF).each_line.map do |line|
  line.chomp
end

@pointer_register = (instr.shift).split("").pop.to_i
INSTRUCTIONS = instr.map{|i| i.split(" ")}.map{|i| [i.shift.to_sym, i.map(&:to_i)].flatten}.freeze


def perform initial_register
  @pointer = 0
  @perf_registers = initial_register
  1.step do |i|
    ip = INSTRUCTIONS[@pointer]
    op,a,b,c = ip
    @perf_registers[@pointer_register] = @pointer
    @perf_registers = OP_MAP[op].call(a,b,c,@perf_registers)
    @pointer = @perf_registers[@pointer_register]
    @pointer += 1

    if V
      puts "*"*25
      puts "#{i} -- #{@pointer} -- #{ip} -- #{@perf_registers}"
    end

    # the upper is set when the instruction pointer loops back to instruction 1
    if @pointer == 1
      # the number is set in register 2
      upper = @perf_registers[2]
      # the result is the sum of all the factors of the number
      puts (1..upper).select{|i| upper % i == 0 }.sum
      break
    end
  end
end

perform([0]*6)
perform([1].concat([0]*5))

__END__
#ip 5
addi 5 16 5
seti 1 0 4
seti 1 8 1
mulr 4 1 3
eqrr 3 2 3
addr 3 5 5
addi 5 1 5
addr 4 0 0
addi 1 1 1
gtrr 1 2 3
addr 5 3 5
seti 2 4 5
addi 4 1 4
gtrr 4 2 3
addr 3 5 5
seti 1 7 5
mulr 5 5 5
addi 2 2 2
mulr 2 2 2
mulr 5 2 2
muli 2 11 2
addi 3 6 3
mulr 3 5 3
addi 3 9 3
addr 2 3 2
addr 5 0 5
seti 0 5 5
setr 5 9 3
mulr 3 5 3
addr 5 3 3
mulr 5 3 3
muli 3 14 3
mulr 3 5 3
addr 2 3 2
seti 0 1 0
seti 0 0 5