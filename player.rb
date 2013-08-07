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
    @facing = :backward
  end

  def observe_before_turn
    @health = @warrior.health
    @last_health ||= @health
    @facing = :forward if @warrior.feel(:backward).wall?
    @ahead = @warrior.feel(@facing)
  end

  def observe_after_turn
    @last_health = @health
  end

  def take_action!
    if @ahead.empty?
      walk_carefully!
    else
      @warrior.attack!(@facing) if @ahead.enemy?
      @warrior.rescue!(@facing) if @ahead.captive?
    end
  end

  def walk_carefully!
      if taking_damage?
        if healthy_enough?
          @warrior.walk!(@facing)
        else
          @warrior.walk!(behind_direction)
        end
      elsif full_health?
        @warrior.walk!(@facing)
      else
        @warrior.rest!
      end
  end

  def ponder_loudly
    puts "Forward: #{@forward}"
    puts "Backward: #{@backward}"
    puts "Taking damage? #{taking_damage?}"
  end

  def taking_damage?
    @last_health > @health
  end

  def full_health?
    @warrior.health == 20
  end

  def behind_direction
    @facing == :backward ? :forward : :backward
  end

  def healthy_enough?
    @last_health == 20
  end

end
