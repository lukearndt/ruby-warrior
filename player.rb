class Player

  def play_turn(warrior)
    @warrior = warrior
    #ponder_loudly
    take_action!
  end

  def initialize
    @facing = :forward
    @enemy_danger =
      {
        "Wizard" => 11,
        "Archer" => 3,
        "Sludge" => 3 / 12,
        "Thick Sludge" => 3 / 24,
      }
    @health_needed_for_melee =
    {
      "Wizard" => 12,
      "Archer" => 7,
      "Sludge" => 10,
      "Thick Sludge" => 16,
      "Captive" => 0
    }
    @health_needed_for_ranged =
    {
      "Wizard" => 1,
      "Archer" => 7,
      "Sludge" => 1,
      "Thick Sludge" => 1,
      "Captive" => 0
    }
    @just_fled_from_archer = false
  end

  def take_action!
    if spot(:forward).enemy? && spot(:backward).enemy?
      attack_most_dangerous!
    elsif @just_fled_from_archer && (@warrior.health >= @health_needed_for_melee["Archer"])
      @warrior.rest!
    elsif spot(:backward).enemy?
      engage_behind!
    elsif spot.captive?
      free_captive_carefully!
    elsif spot.enemy?
      engage!
    elsif spot(:backward).captive?
      turn_around!
    elsif spot.wall?
      turn_around!
    else
      @warrior.walk!
    end
  end

  def attack_most_dangerous!
    if most_dangerous_direction(:forward, :backward) == :forward
      skirmish!
    else
      @warrior.shoot!(:backward)
    end
  end

  def most_dangerous_direction(first, second)
    @enemy_danger[spotted_enemy_type(first)] > @enemy_danger[spotted_enemy_type(second)] ? first : second
  end

  def ranged_enemy?(direction = :forward)
    enemies.include?("Wizard") || enemies.include?("Archer")
  end

  def enemies(direction = :forward)
    enemies = []
    @warrior.look(direction).each do |space|
        enemies << space.to_s if space.enemy?
    end
    enemies
  end

  def engage_behind!
    if ranged_enemy?(:backward)
      @warrior.shoot!(:backward)
    else
      turn_around!
    end
  end

  def free_captive_carefully!
    if @warrior.feel.captive?
      if enemy_behind_enemy?("Archer")
        (healthy_enough_for_melee? || healthy_enough_for_ranged?) ? @warrior.rescue! : @warrior.rest!
      else
        @warrior.rescue!
      end
    else
      @warrior.walk!
    end
  end

  def engage!
    if ranged_enemy?
      if healthy_enough_for_melee?
        charge!
      elsif healthy_enough_for_ranged?
        skirmish!
      end
    elsif healthy_enough_for_melee?
      charge!
    elsif @warrior.feel.enemy?
      @warrior.walk!(:backward)
    elsif ranged_enemy?
      @warrior.walk!(:backward)
      @just_fled_from_archer = true
    elsif healthy_enough_for_melee_with_one_rest?
      @warrior.rest!
    else
      @warrior.shoot!
    end
  end

  def enemy_behind_enemy?(enemy_type)
    if enemies.length < 2
      false
    elsif enemies.length > 1
      enemies[1] == enemy_type
    elsif enemies.length > 2
      enemies[1] == enemy_type ||
      enemies[2] == enemy_type
    end
  end

  def skirmish!
    @warrior.feel.enemy? ? @warrior.attack! : @warrior.shoot!
    @just_fled_from_archer = false
  end

  def charge!
    @warrior.feel.enemy? ? @warrior.attack! : @warrior.walk!
  end

  def turn_around!
    @warrior.pivot!
    @facing = @facing == :forward ? :behind : :forward
  end

  def ponder_loudly
    puts "Facing: #{@facing}"
    puts "First thing ahead: #{spot}"
    puts "Immediately ahead: #{@warrior.feel}"
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

  def spotted_enemy_type(direction = :forward)
    spot(direction).to_s
  end

  def healthy_enough_for_melee?(direction = :forward)
     @warrior.health >= @health_needed_for_melee[spotted_enemy_type] + health_buffer("Archer") + health_buffer("Wizard")
  end

  def healthy_enough_for_melee_with_one_rest?(direction = :forward)
     @warrior.health + 2 >= @health_needed_for_melee[spotted_enemy_type] + health_buffer("Archer") + health_buffer("Wizard")
  end

  def healthy_enough_for_ranged?(direction = :forward)
    @warrior.health >= @health_needed_for_ranged[spotted_enemy_type] + health_buffer("Archer") + health_buffer("Wizard")
  end

  def health_buffer(enemy_type)
    if enemy_behind_enemy?(enemy_type)
      buffer = @health_needed_for_ranged[enemy_type]
    else
      0
    end
  end
end
