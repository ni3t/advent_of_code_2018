require 'pp'
f = File.read('/Users/nbell/dev/advent2018/problems/7/input.txt').split("\n")

INPUT_REGEX = /^S.*([A-Z]).*([A-Z])/

Struct.new("Step", :name, :preconditions)

@steps = []

f.each do |line|
  match = INPUT_REGEX.match(line)
  name = match[2]
  pre = match[1]
  if @steps.select{|s| s.name == name}.length >= 1
    @steps.select{|s| s.name == name}.first.preconditions << pre
  else
    @steps << Struct::Step.new(name, [pre])
  end
end

@all_steps = @steps.map{|s| [s.name].concat(s.preconditions) }.flatten.uniq

@all_steps.map{|s| @steps.select{|s2| s2.name == s}.empty? && @steps << Struct::Step.new(s, [])}

@order = [@steps.select{|s| s.preconditions.empty?}.sort_by{|s| s.name}.first]

@remaining_steps = @steps - @order

until @remaining_steps.empty?
  completed = @order.map(&:name)
  next_steps = @remaining_steps.select{|s| s.preconditions.map{|p| completed.include?(p)}.all?}.sort_by{|s| s.name}
  @remaining_steps -= [next_steps.first]
  @order = @order.concat([next_steps.first])
end

@final = @order.map(&:name).join("")

puts @final

# part 2

Struct.new("Job", :name, :duration, :preconditions, :start_time, :end_time, :worker)

@job_queue = []

@final.each_byte do |c|
  @job_queue << Struct::Job.new( c.chr, c - 4, @steps.select{|s| s.name == c.chr }.first.preconditions )
end

@processing = []

@completed = []

@available_workers = [1,2,3,4,5]

@tick = 0

until @job_queue.empty? && @processing.empty?
  if @processing.map{|j| j.end_time}.include?(@tick)
    @processing.each_with_index do |j,i|
      if j.end_time == @tick
        @completed << @processing.delete_at(i)
        @available_workers << j.worker
      end
    end
  end
  until @available_workers.empty?
    @next_job = nil
    @job_queue.each_with_index do |candidate,i|
      if candidate.preconditions.map{|pc| @completed.map(&:name).include?(pc) }.all?
        @next_job = candidate
        @job_queue.delete_at(i)
        break
      end
    end
    if @next_job.nil?
      break
    end
    @next_job.start_time = @tick
    @next_job.end_time = @tick + @next_job.duration
    @next_job.worker = @available_workers.shift
    @processing << @next_job
  end
  @tick += 1
end

puts @tick - 1