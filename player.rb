class Player

  def play_turn(warrior)
    @warrior = warrior
    observe_before_turn
    ponder_loudly
    take_action!
    observe_after_turn
  end

  def initialize
    @last_health ||= 20
    @cleared_behind = false
    @facing = :forward
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
    if first_thing_ahead.wall?
      turn_around!
    elsif first_thing_ahead.enemy?
      @ahead_melee.enemy? ? @warrior.attack! : @warrior.shoot!
    elsif first_thing_ahead.captive?
      @ahead_melee.captive? ? @warrior.rescue! : @warrior.walk!
    else
      @warrior.walk!
    end
  end

  def turn_around!
    @warrior.pivot!
    @facing = @facing == :forward ? :behind : :forward
  end

  def walk_carefully!
    if taking_damage?
        if healthy_enough?
          @warrior.walk!
        else
          @warrior.walk!(:backward)
        end
      elsif full_health?
        @warrior.walk!
      else
        @warrior.rest!
      end
  end

  def ponder_loudly
    puts "Facing: #{@facing}"
    puts "First thing ahead: #{first_thing_ahead}"
    puts "Immediately ahead: #{@ahead_melee}"
    puts "Behind: #{@warrior.feel(:backward)}"
    puts "Taking damage? #{taking_damage?}"
  end

  def first_thing_ahead
    first_thing = @ahead_melee
    @warrior.look.each do |space|
      if first_thing.empty?
        first_thing = space unless first_thing.stairs?
      end
    end
    first_thing
  end

  def taking_damage?
    @last_health > @health
  end

  def full_health?
    @warrior.health == 20
  end

  def healthy_enough?
    @last_health == 20
  end


end
