class Player < Chingu::GameObject
    has_traits :velocity, :collision_detection, :timer, :effect
    attr_reader :max_steps, :facing
    
    def initialize(options)
      super
        
      @max_steps = 30
      @speed = 3
        
      @image = Image["player.png"]
      self.alpha = 100
      @status = :dead
      @dtheta = 0
      @y_anchor = @y
        
      # banisterfiend
      @facing = :right
      
      
      @cooling_down = false
        
      self.input = {
        #:holding_left => :left, 
        #:holding_right => :right, 
        #:holding_up => :up,
        #:holding_down => :down,
        :space => :fire
      }
        
      #@bounding_box = Rect.new(@x, @y, @image.width, @image.height)
      @bounding_box = Rect.new(@x-@image.width/2, @y-@image.height/2, @image.width, @image.height)
        
      self.rotation_center(:center)
    end
      
    def hit_by(object)
      self.alpha = 50
      Sound["swing.wav"].play(0.4)
      during(500) { @x -= 3; self.factor += 0.01 }.then { self.factor = 1; self.alpha = 100}      
    end
    
    def fire
      return if @cooling_down
      @cooling_down = true
      after(500) { @cooling_down = false }
      
      Sound["swosh.wav"].play
      Bullet.create(:x => @x, :y => @y, :facing => facing)
    end
    
    
    def up
      @velocity_y = -@speed
      handle_collision
      @y_anchor += @velocity_y
    end

    def down
      @velocity_y = @speed
      handle_collision
      @y_anchor += @velocity_y
    end

    def left
      @facing = :left
      @velocity_x = -@speed
      handle_collision
    end
    
    def right
      @facing = :right
      @velocity_x = @speed
      handle_collision    
    end
    
    def handle_collision
      if $window.current_game_state.respond_to?("pixel_collision_at?")
      if $window.current_game_state.pixel_collision_at?(@bounding_box.centerx, @bounding_box.bottom)
        steps = $window.current_game_state.distance_to_surface(@bounding_box.centerx, @bounding_box.bottom)
        
        if steps  < @max_steps
          @y -= steps
          @y_anchor = @y
        else
          @x = @last_x
        end
      end
      end
    end
    
    def update
      
        left  if $window.button_down? Button::KbLeft  or $window.button_down? Button::GpLeft
        right if $window.button_down? Button::KbRight or $window.button_down? Button::GpRight
        up    if $window.button_down? Button::KbUp    or $window.button_down? Button::GpUp
        down  if $window.button_down? Button::KbDown  or $window.button_down? Button::GpDown

      
        # Slow down the playermovement to a halt when dead
        @velocity_x *= 0.90 if @velocity_x.abs <= @speed
        @velocity_y *= 0.90 if @velocity_y.abs <= @speed
        
        @last_x, @last_y = @x, @y   # Move this to trait "velocity"
        
        #
        # Make the ghost "float" up and down when idle
        #
        #
        if @velocity_x.abs < 0.1 and @velocity_y.abs < 0.1
          @dtheta = (@dtheta + 5) % 360
          @dy = 5 * Math::sin(@dtheta / 180.0 * Math::PI)
          @y = @y_anchor + @dy
        else
          @dtheta = 0
          @y_anchor = @y
        end
        
        @bounding_box.x = @x - @image.width/2
        @bounding_box.y = @y - @image.height/2

        handle_collision
                
        # Make sure player-image is turned correctly, use GOSUs draw_rot argument factor_x to achieve this
        # Dont modify when scaling
        if @factor_x.abs == 1
          @factor_x = (@velocity_x >= 0) ? 1 : -1 
        end
    end
end

class Bullet < Chingu::GameObject
  has_trait :collision_detection, :timer
  attr_reader :bounding_box
  
  def initialize(options)
    super
    @image = Image["enemy_ghost_bullet.png"]
    @bounding_box = Rect.new(@x-@image.width/2, @y-@image.height/2, @image.width, @image.height)
    self.rotation_center(:center)
    
    # banisterfiend
    @direc = options[:facing] == :left ? -1 : 1
  end

  def hit_by(object)
    during(50) { self.factor += 1; self.alpha -= 10; }.then { destroy }
  end
  
  def update
    @x += 3 * @direc
    @bounding_box.x = @x - @image.width/2
    @bounding_box.y = @y - @image.height/2
  end
  
end


class AlivePlayer < Chingu::GameObject
    has_traits :velocity, :effect, :collision_detection, :timer
    attr_reader :max_steps
    attr_accessor :status
    
    def initialize(options)
        super
        
        self.rotation_center(:center_bottom)    
        @max_steps = 10
        @speed = 2
        @dt = 0
        @dt_max = 200
        
        @image_alive_1 = Image["player_alive_1.png"]
        @image_alive_2 = Image["player_alive_2.png"]   
        @image = @image_alive_1
        @bounding_box = Rect.new(@x, @y, @image.width, @image.height)
        @status = :default
        @last_direction = :left
        @factor_x - 1
        self.acceleration_y = 0.3 # gravity!
        self.input = { :holding_left => :left, :holding_right => :right }    
    end
    
    def left
        @x -= @speed
        @last_direction = :left
        @status = :walking
        handle_collision
    end
    
    def right
        @x += @speed
        @last_direction = :right
        @status = :walking
        handle_collision    
    end
    
    def handle_collision
        if $window.current_game_state.pixel_collision_at?(@x, @y)
            steps = $window.current_game_state.distance_to_surface(@x, @y)
            if steps  < @max_steps
                @y -= steps
                stop
            else
                @x = @last_x
                self.acceleration_y = 0.3 # gravity!
            end
        end
    end
    
    def update    
        @last_x, @last_y = @x, @y   # Move this to trait "velocity"
        
        super
        handle_collision
        
        # Simple animation between 2 pictures when "alive"
        if @status == :walking
            @dt += $window.dt
            if @dt > @dt_max
                @image = (@image == @image_alive_1) ? @image_alive_2 : @image_alive_1
                @dt = 0
            end
        end
        
        @status = :default
        
        # Make sure player-image is turned correctly, use GOSUs draw_rot argument factor_x to achieve this
        @factor_x = (@last_direction == :right) ? 1 : -1 
    end  
end
