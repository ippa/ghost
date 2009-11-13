class Player < Chingu::GameObject
  has_traits :velocity, :collision_detection, :timer
  attr_reader :max_steps
  
  def initialize(options)
    super
    
    self.input = {  :holding_left => :left, 
                    :holding_right => :right, 
                    :holding_up => :up,
                    :holding_down => :down,
                  }
    self.rotation_center(:center_bottom)
    
    @max_steps = 10
    #@anim = nil
    #@anim = Chingu::Animation.new(:file => "media/player.png", :size => [100,100], :delay => 40)
    #@image = @anim.first
    @image = Image["player.png"]
    @color.alpha = 100
    
    @bounding_box = Rect.new(@x, @y, @image.width, @image.height)

    @status = :stopped
    @speed = 2
  end
            
  def stop   
    @velocity_y = 0
    @acceleration_y = 0
    @status = :stopped
  end
    
  def up
    @velocity_y = -@speed
    handle_collision
  end

  def down
    @velocity_y = @speed
    handle_collision
  end

  def left
    @velocity_x = -@speed
    handle_collision
  end
    
  def right
    @velocity_x = @speed
    handle_collision    
  end
  
  def handle_collision
    if $window.current_game_state.collision?(@x, @y)
      steps = $window.current_game_state.distance_to_surface(@x, @y)
      if steps  < @max_steps
        @y -= steps
        stop
      else
        @x = @last_x
      end
    end
  end
  
  def update
    @velocity_x *= 0.90
    @velocity_y *= 0.90
    
    @last_x, @last_y = @x, @y   # Move this to trait "velocity"
    super
    handle_collision
    
    @image = @anim.next if @anim
    @factor_x = (@velocity_x >= 0) ? 1 : -1  # Make sure player-image is turned correctly
  end  
end
