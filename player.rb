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
  end

  def observe_before_turn
    @health = @warrior.health
    @ahead = @warrior.feel
    @behind = @warrior.feel(:backward)
  end

  def observe_after_turn
    @last_health = @health
  end

  def take_action!
    if @ahead.wall?
      turn_around!
    elsif @ahead.empty?
      walk_carefully!
    else
      @warrior.attack! if @ahead.enemy?
      @warrior.rescue! if @ahead.captive?
    end
  end

  def turn_around!
    @warrior.pivot!
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
    puts "Ahead: #{@ahead}"
    puts "Behind: #{@warrior.feel(:backward)}"
    puts "Taking damage? #{taking_damage?}"
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
