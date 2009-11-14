class Screen < Chingu::GameState
  attr_reader :map
  
  def initialize(options = {})
    super
    
    self.input = { :e => Chingu::GameStates::Edit }
    
    @image ||= options[:image]
    @clouds = options[:clouds] || 15
    @mode = options[:mode] || :dead
    
    @background = GameObject.create(:image => @image, :zorder => 10)
    @background.rotation_center(:top_left)
    
    @map = Hash.new
    @width = 800
    @height = 600
        
    if @mode == :alive
      @player = AlivePlayer.create(:x => 330, :y => 500, :zorder => 100)
      @sky1 = Color.new(0xFFACFFEC)
      @sky2 = Color.new(0xFF0012FF)     
    else
      @player = Player.create(:x => 230, :y => 380, :zorder => 100)
      @sky1 = Color.new(0xFF510009)
      @sky2 = Color.new(0xFF111111)      
    end
    
    @clouds.times do |nr|
      Fog.create(:x => (nr-1) * ($window.width/@clouds) - 100, :y => $window.height - 70 - rand(50))
    end
    
    load_game_objects
  end
  
  def game_object_at(x, y)
    game_objects.select do |game_object| 
      game_object.respond_to?(:bounding_box) && game_object.bounding_box.collide_point?(x,y)
    end.first
  end
  
  def collision?(x, y)
    return false    if outside_window?(x, y)
    not @background.image.transparent_pixel?(x, y)
  end
  
  def outside_window?(x, y)    
    x <= 0 || x >= @background.image.width || y <= 0 || y >= @background.image.height
  end
  
  def distance_to_surface(x, y, max_steps = nil)
    steps = 0
    steps += 1  while collision?(x, y - steps) && (y - steps) > 0
    return steps
  end
  
  def update
    super
    
    Fog.destroy_if { |fog| fog.right < 0 || fog.x > @width}
    Fog.create(:x => @width, :y => @height - 70 - rand(50)) if Fog.size < @clouds
      
    $window.caption = "Ghost. FPS: #{$window.fps}. X/Y: #{@player.x}/#{@player.y}"
    
    if @player.x >= @width
      switch_game_state(@map[:right])
      @player.x = 1
    elsif @player.x < 0
      switch_game_state(@map[:left])
      @player.x = @width - 1
    elsif @player.y > @height
      @player.y = 1
      switch_game_state(@map[:down])
    elsif @player.y < 0
      @player.y = @height - 1
      switch_game_state(@map[:up])
    end
    
    #@player.each_bounding_box_collision(Enemy) do |me, enemy|
    #  @player.zap   if enemy.is_a? Spark
    #end
  end
  
  def draw
    fill_gradient(:from => @sky2, :to => @sky1, :zorder => -1)
    
    super
  end
end

class Fog < GameObject
  has_trait :velocity
  def initialize(options)
    super
    self.rotation_center(:top_left)
    @image = rand(5) < 4 ? Image["cloud.png"] : Image["cloud2.png"]
    @color.alpha = 5 + rand(15)
    @velocity_x = -rand/5 + rand/5
    self.factor = 1 + rand*2
  end
  
  def right
    @x + @image.width * @factor_x
  end
  
end


class Alive1 < Screen
  def initialize(options = {})
    super(options.merge(:image => "screen1_alive.png", :clouds => 0, :mode => :alive))
    @map[:up] = Screen1
    
    @truck = GameObject.create(:x => $window.width, :y => $window.height-70, :image => Image["truck.png"], :rotation_center => :left_bottom)
    @truck_endpoint = $window.width - 150
    @player_hit = false
  end
  
  def update
    super 
        
    if @player.x > @truck_endpoint && @truck.x > @truck_endpoint
      @truck.x -= 10
    end
    
    if @truck.x <= @truck_endpoint && @player_hit == false
      #puts "Hit by truck!"
      @player_hit = true
      @player.velocity_x  = -10
      @player.velocity_y  = -10
      @player.rotation_rate = 8
    end
  end
end

class Screen1 < Screen
  def initialize(options = {})
    super(options.merge(:image => "screen1.png"))
    @map[:right] = Screen2
  end  
end


class Screen2 < Screen
  def initialize(options = {})
    super(options.merge(:image => "screen2.png"))
    @map[:left] = Screen1
    @map[:right] = Screen2
  end  
end


class Screen3 < Screen
  def initialize(options = {})
    super(options.merge(:image => "screen3.bmp"))
    @map[:left] = Screen2
  end
  
  def setup
  end
end
