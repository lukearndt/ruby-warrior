class Player

  def play_turn(warrior)
    @warrior = warrior
    observe_before_turn
    #ponder_loudly
    take_action!
    observe_after_turn
  end

  def initialize
    @last_health ||= 20
    @cleared_behind = false
    @facing = :forward
    @enemy_danger =
      {
        "Wizard" => 11,
        "Archer" => 3,
        "Sludge" => 3 / 12,
        "Thick Sludge" => 3 / 24,
      }
  end

  def observe_before_turn
    @health = @warrior.health
    @ahead_melee = @warrior.feel
    @behind = @warrior.feel(:backward)
  end

  def observe_after_turn
    @last_health = @health
  end

  def take_action!
    if spot(:forward).enemy? && spot(:backward).enemy?
      attack_priority!
    elsif spot.enemy?
      fight!
    elsif spot(:backward).enemy?
      turn_around!
    elsif spot.captive?
      @ahead_melee.captive? ? @warrior.rescue! : @warrior.walk!
    elsif spot(:backward).captive?
      turn_around!
    elsif spot.wall?
      turn_around!
    elsif badly_injured?
      @warrior.rest!
    else
      @warrior.walk!
    end
  end


  def attack_priority!
    if most_dangerous_direction(:forward, :backward) == :forward
      fight!
    else
      if spot(:backward).to_s == "w" && "a"
        @warrior.shoot!(:backward)
      else
        turn_around!
      end
    end
  end

  def most_dangerous_direction(first, second)
    @enemy_danger[spot(first).to_s] > @enemy_danger[spot(second).to_s] ? first : second
  end

  def fight!
    @ahead_melee.enemy? ? @warrior.attack! : @warrior.shoot!
  end

  def turn_around!
    @warrior.pivot!
    @facing = @facing == :forward ? :behind : :forward
  end

  def ponder_loudly
    puts "Facing: #{@facing}"
    puts "First thing ahead: #{spot}"
    puts "Immediately ahead: #{@ahead_melee}"
    puts "Behind: #{@warrior.feel(:backward)}"
    puts "Taking damage? #{taking_damage?}"
  end

  def spot(direction = :forward)
    first_thing = @warrior.feel(direction)
    @warrior.look(direction).each do |space|
      if first_thing.empty?
        first_thing = space unless first_thing.stairs?
      end
    end
    first_thing
  end

  def full_health?
    @warrior.health == 20
  end

  def badly_injured?
    @warrior.health < 12
  end

end
