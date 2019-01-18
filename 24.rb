VERBOSE = ARGV.delete("-v")

Army = Struct.new(:groups) do
  def select_targets
    groups.sort_by(&:sort_order).reverse.map(&:select_target)
  end

  def dead
    groups.sum(&:count) == 0
  end
end

Group = Struct.new(:id, :count, :hp, :immunities, :weaknesses, :attack_damage, :attack_type, :initiative, :selected_target, :opponent, :targeted) do
  def effective_power
    count * attack_damage
  end

  def sort_order
    effective_power << 20 ^ initiative
  end

  def select_target
    return if count == 0
    target = opponent
      .groups
      .reject { |g| g.targeted == true || g&.count == 0 }
      .each { |g| (puts "#{display_team} group #{display_id} would deal defending group #{g.display_id} #{g.potential_damage(self.effective_power, self.attack_type)} damage") if VERBOSE }
      .sort_by { |g| g.potential_damage_sort(attack_damage, attack_type) }
      .compact
      .reverse
      .reject { |g| g.potential_damage_sort(attack_damage, attack_type) == 0 }
      .instance_eval { any? ? first : nil }
    target && target.set_as_target
    self.selected_target = target
  end

  def set_as_target
    self.targeted = true
  end

  def potential_damage(amount, type)
    if immunities.include? type
      0
    elsif weaknesses.include? type
      amount * 2
    else
      amount
    end
  end

  def potential_damage_sort(amount, type)
    if immunities.include? type
      (effective_power) << 5 ^ initiative
    elsif weaknesses.include? type
      ((2 * amount) << 5 ^ effective_power) << 5 ^ initiative
    else
      (amount << 5 ^ effective_power) << 5 ^ initiative
    end
  end

  def receive_damage(amount, type)
    if immunities.include? type
      return
    elsif weaknesses.include? type
      self.count = [self.count - (2 * amount / hp), 0].max
    else
      self.count = [self.count - (amount / hp), 0].max
    end
  end

  def display_id
    self.id.split("").last
  end

  def display_team
    self.id.split("")[1] == ?n ? "Infection" : "Immune System"
  end
end

IMMUNE = Army.new([])
INFECT = Army.new([])
if ARGV.delete("-t")
  i = 1.step
  j = 1.step

  IMMUNE.groups << Group.new("imm#{i.next}", 17, 5390, [], [?R, ?B], 4507, ?F, 2)
  IMMUNE.groups << Group.new("imm#{i.next}", 989, 1274, [?F], [?B, ?S], 25, ?S, 3)

  INFECT.groups << Group.new("inf#{j.next}", 801, 4706, [], [?R], 116, ?B, 1)
  INFECT.groups << Group.new("inf#{j.next}", 4485, 2961, [?R], [?F, ?C], 12, ?S, 4)

  IMMUNE.groups.map { |g| g.opponent = INFECT }
  INFECT.groups.map { |g| g.opponent = IMMUNE }
else
  i = 1.step
  j = 1.step

  # immune:
  # 2728 units each with 5703 hit points (weak to fire) with an attack that does 18 cold damage at initiative 12
  # 916 units each with 5535 hit points (weak to bludgeoning) with an attack that does 55 slashing damage at initiative 20
  # 2255 units each with 7442 hit points (weak to radiation) with an attack that does 31 bludgeoning damage at initiative 8
  # 112 units each with 4951 hit points (immune to cold) with an attack that does 360 fire damage at initiative 9
  # 7376 units each with 6574 hit points (immune to cold, slashing, fire) with an attack that does 7 bludgeoning damage at initiative 4
  # 77 units each with 5884 hit points (weak to slashing) with an attack that does 738 radiation damage at initiative 6
  # 6601 units each with 8652 hit points (weak to fire, cold) with an attack that does 11 fire damage at initiative 19
  # 3259 units each with 10067 hit points (weak to bludgeoning) with an attack that does 29 cold damage at initiative 13
  # 2033 units each with 4054 hit points (immune to cold; weak to fire, slashing) with an attack that does 18 slashing damage at initiative 3
  # 3109 units each with 3593 hit points with an attack that does 9 bludgeoning damage at initiative 11
  # infection:
  # 1466 units each with 57281 hit points (weak to slashing, fire) with an attack that does 58 slashing damage at initiative 7
  # 247 units each with 13627 hit points with an attack that does 108 fire damage at initiative 15
  # 1298 units each with 41570 hit points (immune to fire, bludgeoning) with an attack that does 63 fire damage at initiative 14
  # 2161 units each with 40187 hit points (weak to fire) with an attack that does 33 slashing damage at initiative 5
  # 57 units each with 55432 hit points (weak to cold) with an attack that does 1687 radiation damage at initiative 17
  # 3537 units each with 24220 hit points (weak to cold) with an attack that does 11 fire damage at initiative 10
  # 339 units each with 44733 hit points (immune to cold, bludgeoning; weak to radiation, fire) with an attack that does 258 cold damage at initiative 18
  # 1140 units each with 17741 hit points (weak to bludgeoning; immune to fire, slashing) with an attack that does 25 fire damage at initiative 2
  # 112 units each with 44488 hit points (weak to bludgeoning, radiation; immune to cold) with an attack that does 749 radiation damage at initiative 16
  # 2918 units each with 36170 hit points (immune to bludgeoning; weak to slashing, cold) with an attack that does 24 radiation damage at initiative 1
  IMMUNE.groups << Group.new("imm#{i.next}", 2728, 5703, [], [?F], 18, ?C, 12)
  IMMUNE.groups << Group.new("imm#{i.next}", 916, 5535, [], [?B], 55, ?S, 20)
  IMMUNE.groups << Group.new("imm#{i.next}", 2255, 7442, [], [?R], 31, ?B, 8)
  IMMUNE.groups << Group.new("imm#{i.next}", 112, 4951, [?C], [], 360, ?F, 9)
  IMMUNE.groups << Group.new("imm#{i.next}", 7376, 6574, [?C, ?S, ?F], [], 7, ?B, 4)
  IMMUNE.groups << Group.new("imm#{i.next}", 77, 5884, [], [?S], 738, ?R, 6)
  IMMUNE.groups << Group.new("imm#{i.next}", 6601, 8652, [], [?F, ?C], 11, ?F, 19)
  IMMUNE.groups << Group.new("imm#{i.next}", 3259, 10067, [], [?B], 29, ?C, 13)
  IMMUNE.groups << Group.new("imm#{i.next}", 2033, 4054, [?C], [?F, ?S], 18, ?S, 3)
  IMMUNE.groups << Group.new("imm#{i.next}", 3109, 3593, [], [], 9, ?B, 11)
  INFECT.groups << Group.new("inf#{j.next}", 1466, 57281, [], [?S, ?F], 58, ?S, 7)
  INFECT.groups << Group.new("inf#{j.next}", 247, 13627, [], [], 108, ?F, 15)
  INFECT.groups << Group.new("inf#{j.next}", 1298, 41570, [?F, ?B], [], 63, ?F, 14)
  INFECT.groups << Group.new("inf#{j.next}", 2161, 40187, [], [?F], 33, ?S, 5)
  INFECT.groups << Group.new("inf#{j.next}", 57, 55432, [], [?C], 1687, ?R, 17)
  INFECT.groups << Group.new("inf#{j.next}", 3537, 24220, [], [?C], 11, ?F, 10)
  INFECT.groups << Group.new("inf#{j.next}", 339, 44733, [?C, ?B], [?R, ?F], 258, ?C, 18)
  INFECT.groups << Group.new("inf#{j.next}", 1140, 17741, [?F, ?S], [?B], 25, ?F, 2)
  INFECT.groups << Group.new("inf#{j.next}", 112, 44488, [?C], [?B, ?R], 749, ?R, 16)
  INFECT.groups << Group.new("inf#{j.next}", 2918, 36170, [?B], [?S, ?C], 24, ?R, 1)

  IMMUNE.groups.map { |g| g.opponent = INFECT }
  INFECT.groups.map { |g| g.opponent = IMMUNE }
end

ALL_GROUPS = [IMMUNE.groups, INFECT.groups].flatten

def go_a_round(i)
  (puts "Immune System:"
    IMMUNE.groups.map do |g|
    (puts "Group #{g.display_id} contains #{g.count} units") if g.count > 0
  end
    puts "Infection:"
    INFECT.groups.map do |g|
    puts "Group #{g.display_id} contains #{g.count} units"
  end
    puts "") if VERBOSE
  [INFECT, IMMUNE].map(&:select_targets)
  (puts "" if VERBOSE)
  ALL_GROUPS.reject { |g| g.count == 0 }.sort_by { |g| g.initiative }.reverse.map do |g|
    alive_before = g&.selected_target&.count
    g&.selected_target&.receive_damage(g.effective_power, g.attack_type)
    alive_after = g&.selected_target&.count
    alive_before && alive_after && killing = alive_before - alive_after
    (puts "#{g.display_team} group #{g.display_id} attacks defending group #{g.selected_target.display_id}, killing #{killing} units" if VERBOSE && killing && killing > 0)
    g.selected_target&.targeted = false
    g.selected_target = nil
  end
  (puts "-" * 25) if VERBOSE
end

i = 1.step
until [IMMUNE, INFECT].any?(&:dead)
  go_a_round(i.next)
end

puts ALL_GROUPS.map(&:count).sum

__END__
Immune System:
2728 units each with 5703 hit points (weak to fire) with an attack that does 18 cold damage at initiative 12
916 units each with 5535 hit points (weak to bludgeoning) with an attack that does 55 slashing damage at initiative 20
2255 units each with 7442 hit points (weak to radiation) with an attack that does 31 bludgeoning damage at initiative 8
112 units each with 4951 hit points (immune to cold) with an attack that does 360 fire damage at initiative 9
7376 units each with 6574 hit points (immune to cold, slashing, fire) with an attack that does 7 bludgeoning damage at initiative 4
77 units each with 5884 hit points (weak to slashing) with an attack that does 738 radiation damage at initiative 6
6601 units each with 8652 hit points (weak to fire, cold) with an attack that does 11 fire damage at initiative 19
3259 units each with 10067 hit points (weak to bludgeoning) with an attack that does 29 cold damage at initiative 13
2033 units each with 4054 hit points (immune to cold; weak to fire, slashing) with an attack that does 18 slashing damage at initiative 3
3109 units each with 3593 hit points with an attack that does 9 bludgeoning damage at initiative 11

Infection:
1466 units each with 57281 hit points (weak to slashing, fire) with an attack that does 58 slashing damage at initiative 7
247 units each with 13627 hit points with an attack that does 108 fire damage at initiative 15
1298 units each with 41570 hit points (immune to fire, bludgeoning) with an attack that does 63 fire damage at initiative 14
2161 units each with 40187 hit points (weak to fire) with an attack that does 33 slashing damage at initiative 5
57 units each with 55432 hit points (weak to cold) with an attack that does 1687 radiation damage at initiative 17
3537 units each with 24220 hit points (weak to cold) with an attack that does 11 fire damage at initiative 10
339 units each with 44733 hit points (immune to cold, bludgeoning; weak to radiation, fire) with an attack that does 258 cold damage at initiative 18
1140 units each with 17741 hit points (weak to bludgeoning; immune to fire, slashing) with an attack that does 25 fire damage at initiative 2
112 units each with 44488 hit points (weak to bludgeoning, radiation; immune to cold) with an attack that does 749 radiation damage at initiative 16
2918 units each with 36170 hit points (immune to bludgeoning; weak to slashing, cold) with an attack that does 24 radiation damage at initiative 1
