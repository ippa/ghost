class Player < Chingu::GameObject
    has_traits :velocity, :collision_detection, :timer
    attr_reader :max_steps
    
    def initialize(options)
        super
        
        @max_steps = 10
        @speed = 2
        
        @image = Image["player.png"]
        @color.alpha = 100
        @status = :dead
        @dtheta = 0
        @y_anchor = @y
        
        
        self.input = {  :holding_left => :left, 
            :holding_right => :right, 
            :holding_up => :up,
            :holding_down => :down,
        }
        
        self.rotation_center(:center_bottom)
        
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
        # Slow down the playermovement to a halt when dead
        @velocity_x *= 0.90
        @velocity_y *= 0.90
        
        #
        # Make the ghost "float" up and down when idle
        #
        if @velocity_x.abs < 0.1 and @velocity_y.abs < 0.1
            @dtheta = (@dtheta + 5) % 360
            @dy = 5 * Math::sin(@dtheta / 180.0 * Math::PI)
            @y = @y_anchor + @dy
        else
           # @dtheta = 0
        end
        
        @last_x, @last_y = @x, @y   # Move this to trait "velocity"
        super
        handle_collision
        
        # Make sure player-image is turned correctly, use GOSUs draw_rot argument factor_x to achieve this
        @factor_x = (@velocity_x >= 0) ? 1 : -1 
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
        if $window.current_game_state.collision?(@x, @y)
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
