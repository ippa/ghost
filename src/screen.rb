class Screen < Chingu::GameState
  attr_reader :map
  
  def initialize(options = {})
    super
    
    self.input = { :e => Chingu::GameStates::Edit }
    
    @image ||= options[:image]
    @player ||= $window.player
    
    @background = GameObject.create(:image => @image, :zorder => 10)
    @background.rotation_center(:top_left)
    
    @map = Hash.new
    @width = 800
    @height = 600
    
    @sky1 = Color.new(0xFF510009)
    @sky2 = Color.new(0xFF111111)

    @fog_amount = 15
    @fog_amount.times do |nr|
      Fog.create(:x => (nr-1) * ($window.width/@fog_amount) - 100, :y => $window.height - 70 - rand(50))
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
    Fog.create(:x => @width, :y => @height - 70 - rand(50)) if Fog.size < @fog_amount
      
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
    
    @player.each_bounding_box_collision(Enemy) do |me, enemy|
      @player.zap   if enemy.is_a? Spark
    end
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
    @velocity_x = -rand/10 + rand/10
    self.factor = 1 + rand*2
  end
  
  def right
    @x + @image.width * @factor
  end
  
end

class Screen1 < Screen
  def initialize(options = {})
    super(options.merge(:image => "screen1.png"))
    @map[:right] = Screen2
  end
  
  #def setup
  #  @player.unpause!
  #end
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
