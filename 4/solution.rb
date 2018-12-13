require 'pp'
f = File.read('/Users/nbell/dev/advent2018/problems/4/input.txt').split("\n")

# example:
# [1518-10-31 00:58] wakes up

LINE_REGEX = /^\[1518-(\d{2})-(\d{2}) (\d{2}):(\d{2})\].*(begins|wakes|falls).*$/
GUARD_REGEX = /\] Guard #(.*) b/

Struct.new('Observation', :id, :month, :day, :hour, :minute, :guard, :type)
Struct.new('Shift', :guard, :sleeps)
Struct.new('Guard', :guard, :sleeps, :total_minutes_slept)
@observations = []

f.map do |observation|
  row = LINE_REGEX.match(observation)
  guard = GUARD_REGEX.match(observation) ? GUARD_REGEX.match(observation)[1] : nil
  @observations << Struct::Observation.new(nil, row[1], row[2], row[3], row[4], guard, row[5])
end

@sorted_observations = @observations.group_by(&:month).sort.map do |month|
  month[1].group_by(&:day).sort.map do |day|
    day[1].group_by(&:hour).sort.map do |hour|
      hour[1].group_by(&:minute).sort.map do |minute|
        minute[1]
      end
    end
  end
end.flatten.each_with_index do |observation, i|
  observation.id = i
  if observation.guard
    @guard = observation.guard
  else
    observation.guard = @guard
  end
  observation
end

@shifts = []

@sorted_observations.each do |observation|
  if observation.type == 'begins'
    shift = Struct::Shift.new(observation.guard)
    @shifts << shift
  end
  if observation.type == 'falls'
    if @shifts.last.sleeps.nil?
      @shifts.last.sleeps = [{ begin: observation.minute.to_i }]
    else
      @shifts.last.sleeps << { begin: observation.minute.to_i }
    end
  end
  next unless observation.type == 'wakes'
  length = observation.minute.to_i - @shifts.last.sleeps.last[:begin]
  @shifts.last.sleeps.last[:end] = observation.minute.to_i
  @shifts.last.sleeps.last[:length] = length
end

@guards = []

@shifts.group_by(&:guard).each do |guard_pair|
  sleeps = guard_pair[1].map(&:sleeps).compact.flatten
  total_minutes_slept = 0
  unless sleeps.empty?
    total_minutes_slept = sleeps.map { |s| s[:length] }.inject(&:+)
  end
  @guards << Struct::Guard.new(guard_pair[0], sleeps, total_minutes_slept)
end

sleepiest_guard = @guards.max_by(&:total_minutes_slept)

array_of_minutes = Array.new(60) { |i| { minute: i, times_slept: 0 } }

sleepiest_guard.sleeps.each do |sleep_session|
  (sleep_session[:begin]...sleep_session[:end]).each do |i|
    array_of_minutes[i][:times_slept] = array_of_minutes[i][:times_slept] + 1
  end
end

sleepiest_guard_sleepiest_time = array_of_minutes.max_by{|minute| minute[:times_slept]}[:minute]

puts sleepiest_guard.guard.to_i * sleepiest_guard_sleepiest_time

guard_maxes = @guards.map do |guard|
  array_of_minutes = Array.new(60) { |i| { minute: i, times_slept: 0 } }
  guard.sleeps.each do |sleep_session|
    (sleep_session[:begin]...sleep_session[:end]).each do |i|
      array_of_minutes[i][:times_slept] = array_of_minutes[i][:times_slept] + 1
    end
  end
  res = { id: guard.guard, max_count: array_of_minutes.max_by{|m| m[:times_slept]}[:times_slept], max_minute: array_of_minutes.max_by { |m| m[:times_slept] }[:minute] }
end.compact.max_by{|guard| guard[:max_count]}

pp guard_maxes[:id].to_i * guard_maxes[:max_minute].to_i