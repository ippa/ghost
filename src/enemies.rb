class EnemyGhost < Chingu::GameObject
  has_trait :collision_detection, :timer
  attr_reader :bounding_box
  
  def initialize(options)
    super
    
    @image = Image["enemy_ghost.png"]
    @bounding_box = Rect.new(@x, @y, @image.width, @image.height)
    self.rotation_center(:center)
    
    every(2000) { fire_at_player }
  end
  
  def update
    @x -= 1
    @last_direction =# :left
    @factor_x = (@last_direction == :right) ? 1 : -1     
  end
  
  def fire_at_player
    bullet = EnemyGhostBullet.create(:x => @x, :y => @y)    
  end
  
end

class EnemyGhostBullet < Chingu::GameObject
  has_trait :collision_detection, :velocity
  attr_reader :bounding_box
  
  def initialize(options)
    super
  
    # velocity_x and velocity_y will be read by trait 'velocity' and applied to x and y
    self.velocity_x = ($window.current_game_state.player.x - @x) / 100
    self.velocity_y = ($window.current_game_state.player.y - @y) / 100
    
    puts self.velocity_x
    puts self.velocity_y
    
    @image = Image["enemy_ghost_bullet.png"]
    @bounding_box = Rect.new(@x, @y, @image.width, @image.height)
    self.rotation_center(:center)
  end
  
end