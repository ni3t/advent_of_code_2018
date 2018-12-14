require 'pp'
INPUT = 236021
START = 3710

@scores = START.to_s.chars.map(&:to_i)
@elves = [0,1]

20_000_000.times do
    elf_scores = [@scores[@elves[0]],@scores[@elves[1]]]
    @scores.concat(elf_scores.inject(&:+).to_s.chars.map(&:to_i))
    @elves = @elves.each_with_index.map do |elf,i|
        new_pos = (elf + 1 + elf_scores[i]) % @scores.length
        new_pos
    end
end



pp @scores[INPUT...(INPUT+10)].map(&:to_s).join

@cur_idx = 0
until @matched || @cur_idx >= 100
    str = @scores[0...1e9].join
    if str.match(/236021/)
        idx = @cur_idx * 1_000_000
        @matched = true
        idx += str.index /236021/ 
        puts idx
    else
        nil
    end
    @cur_idx += 1
    @scores.rotate!(1e9)
end

