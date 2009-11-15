class EnemyGhost < Chingu::GameObject
  has_trait :collision_detection, :timer
  attr_reader :bounding_box
  
  def initialize(options)
    super
    
    @image = Image["enemy_ghost.png"]
    @bounding_box = Rect.new(@x-@image.width/2, @y-@image.width/2, @image.width, @image.height)
    self.rotation_center(:center)
    
    @factor_x = -1    # Turn sprite left
    
    every(2000) { fire_at_player }
  end
  
  def update
    @x -= 1
    @bounding_box.x = @x - @image.width/2
    @bounding_box.y = @y - @image.width/2    
  end
  
  def fire_at_player
    bullet = EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y)    
  end
  
  def hit_by(object)
    during(50) { self.factor += 1; @color.alpha -= 10; }.then { destroy }
  end  
  
end

class EnemyGhostBullet < Chingu::GameObject
  has_trait :collision_detection, :velocity, :timer
  attr_reader :bounding_box
  
  def initialize(options)
    super
  
    # velocity_x and velocity_y will be read by trait 'velocity' and applied to x and y
    self.velocity_x = ($window.current_game_state.player.x - @x) / 100
    self.velocity_y = ($window.current_game_state.player.y - @y) / 100
    
    puts self.velocity_x
    puts self.velocity_y
    
    @image = Image["enemy_ghost_bullet.png"]
    @bounding_box = Rect.new(@x-@image.width/2, @y-@image.width/2, @image.width, @image.height)
    self.rotation_center(:center)
  end

  def hit_by(object)
    during(50) { self.factor += 1; @color.alpha -= 10; }.then { destroy }
  end  
  
  def update
    @bounding_box.x = @x - @image.width/2
    @bounding_box.y = @y - @image.width/2
  end
  
end