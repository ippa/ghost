class EnemyGhost < Chingu::GameObject
  has_trait :collision_detection, :timer, :bounding_box
  
  def initialize(options)
    super
    
    @type = options[:type] || 1
    @image = Image["enemy_ghost.png"]
    rotation_center(:center)
    
    @red = Color.new(0xFFFF0000)
    @green = Color.new(0xFF00FF00)
    @blue = Color.new(0xFFAA00AA)
    
    #
    # We have 3 different kind of ghosts, defaults to type #1
    #
    if @type == 1
      @color = @red.dup
      @speed = 1
      @fire_rate = 2000
    elsif @type == 2
      @color = @green.dup
      @speed = 2
      @fire_rate = 1500
    elsif @type == 3
      @color = @blue.dup
      @speed = 2
      @fire_rate = 1000
    end
    
    @factor_x = -1              # Turn sprite left    
    every(@fire_rate) { fire }  # Fire a bullet every @fire_rate millisecond
    update_trait  # this seems to be needed to init the bounding_box correclty, investigate!
  end
  
  def update
    @x -= @speed
  end
  
  def fire
    Sound["swosh.wav"].play
    bullet = EnemyGhostBullet.create(:x => self.bounding_box.left, :y => @y, :color => @color)
  end
  
  def hit_by(object)
    Sound["breath.wav"].play(0.5)
    during(250) { self.factor_y += 0.03; self.alpha -= 1; }.then { destroy }
  end  
  
end


class EnemySpirit < Chingu::GameObject
  has_trait :collision_detection, :timer, :bounding_box
  
  def initialize(options)
    super
    
    @type = options[:type] || 1
    @y = options[:y] || $window.height
    @x_anchor = @x
    @dtheta = rand(360)

    # amplitude of sine wave
    @amp = rand(7)
    
    @image = Image["enemy_spirit.png"]
    self.rotation_center(:center)
    
    #
    # We have 3 different kind of spirits, defaults to type #1
    #
    if @type == 1
      @speed = 1
      @fire_rate = 4000
    elsif @type == 2
      @speed = 1
      @fire_rate = 3000
    elsif @type == 3
      @speed = 1
      @fire_rate = 2000
    end
    
    # Start out transparent, fade in
    self.alpha = 0
    during(1000) { self.alpha += 1}

    @factor_x = -1              # Turn sprite left    
    every(@fire_rate) { fire }  # Fire a bullet every @fire_rate millisecond
    update_trait  # this seems to be needed to init the bounding_box correclty, investigate!
  end
  
  def update
    @dtheta = (@dtheta + 5) % 360
    @dx = @amp * Math::sin(@dtheta / 180.0 * Math::PI)
    @x = @x_anchor + @dx
    @y -= @speed
  end
  
  def fire
    Sound["swosh.wav"].play
    EnemyGhostBullet.create(:x => self.bounding_box.left, :y => @y)
    
    if @type == 2
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => -150)
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => 150)
    elsif @type == 3
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => -250)
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => -150)
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => 150)
      EnemyGhostBullet.create(:x => @bounding_box.left, :y => @y, :y_offset => 250)
    end

  end
  
  def hit_by(object)
    Sound["breath.wav"].play(0.4)
    during(250) { self.factor_y += 0.03; self.alpha -= 1; }.then { destroy }
  end  
  
end



class EnemyGhostBullet < Chingu::GameObject
  has_trait :collision_detection, :velocity, :timer, :bounding_box
 
  def initialize(options)
    super
  
    @y_offset = options[:y_offset] || 0
    
    # velocity_x and velocity_y will be read by trait 'velocity' and applied to x and y
    self.velocity_x = ($window.current_game_state.player.x - @x) / 100
    self.velocity_y = ($window.current_game_state.player.y - @y + @y_offset) / 100
        
    @image = Image["enemy_ghost_bullet.png"]
    self.rotation_center(:center)
    
    update_trait  # this seems to be needed to init the bounding_box correclty, investigate!
  end

  def hit_by(object)
    during(50) { self.factor += 1; self.alpha -= 10; }.then { destroy }
  end  
end
