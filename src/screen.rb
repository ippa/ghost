class Screen < Chingu::GameState
  attr_reader :map, :player
  
  def initialize(options = {})
    super
    
    self.input = { :e => Chingu::GameStates::Edit }
    
    @image = options[:image] || "#{self.class.to_s.downcase}.png"
    @clouds = options[:clouds] || 15
    @enter_x = options[:enter_x] || 230
    @enter_y = options[:enter_y] || 380
    
    @background = GameObject.create(:image => @image, :zorder => 10, :rotation_center => :top_left)
    
    @game_states = Hash.new
    @width = 800
    @height = 600
        
    @player = Player.create(:x => @enter_x, :y => @enter_y, :zorder => 100)
    @sky1 = Color.new(0xFF510009)
    @sky2 = Color.new(0xFF111111)
    
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
      
    $window.caption = "Ghost. Screen: #{self.class.to_s}. FPS: #{$window.fps}. X/Y: #{@player.x}/#{@player.y}"
    
    if @player.x >= @width
      switch_game_state(@game_states[:right].new(:enter_x => 1, :enter_y => @player.y))
    elsif @player.x < 0
      switch_game_state(@game_states[:left].new(:enter_x => @width-1, :enter_y => @player.y))
    elsif @player.y > @height
      switch_game_state(@game_states[:down].new(:enter_x => @player.x, :enter_y => 1))
    elsif @player.y < 0
      switch_game_state(@game_states[:up].new(:enter_x => @player.x, :enter_y => @height-1))
    end
    
    @player.each_bounding_box_collision([EnemyGhost, EnemyGhostBullet]) do |me, enemy|
      @player.hit_by(enemy)
      enemy.hit_by(@player) if enemy.is_a? EnemyGhostBullet
    end
    
    Bullet.each_bounding_box_collision([EnemyGhost, EnemySpirit]) do |bullet, enemy|
      enemy.hit_by(bullet)
      bullet.hit_by(enemy)
    end
    
    game_objects.destroy_if { |game_object| game_object.outside_window? }
    
  end
  
  def draw
    fill_gradient(:from => @sky2, :to => @sky1, :zorder => -1)    
    super
  end
  
end


class Screen1 < Screen
  def initialize(options = {})
    super
    @game_states[:right] = Screen2
    Song["wind.ogg"].play(true)
  end
  
  def setup
    EnemySpirit.create(:x => 400)
  end
end

class Screen2 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen1
    @game_states[:right] = Screen3
  end

  def setup
    #EnemySpirit.create(:x => 600)
    #EnemyGhost.create(:x => @width - 20, :y => 200)
    #EnemyGhost.create(:x => @width - 20, :y => 300, :type => 2)    
  end
end


class Screen3 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen2
    @game_states[:right] = Screen4
  end
  
  def setup
    EnemyGhost.create(:x => @width - 20, :y => 100)
    EnemyGhost.create(:x => @width - 60, :y => 200)
    EnemyGhost.create(:x => @width - 100, :y => 300)    
  end  
end


class Screen4 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen3
    @game_states[:right] = Screen5
  end
  
  def setup
    EnemyGhost.create(:x => @width - 100, :y => 50)
    EnemyGhost.create(:x => @width - 50, :y => 100)
  end  
  
end


class Screen5 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen4
    @game_states[:right] = Screen6
  end
end


class Screen6 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen5
    @game_states[:right] = Screen7
  end
end


class Screen7 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen6
    @game_states[:right] = Screen8
  end
end


class Screen8 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen7
    @game_states[:right] = Screen9
  end
end


class Screen9 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen8
    @game_states[:right] = Screen10
  end
  
  def setup
    EnemySpirit.create(:x => 200)
    EnemySpirit.create(:x => 300)
  end

end

class Screen10 < Screen
  def initialize(options = {})
    super
    @game_states[:left] = Screen9
    @game_states[:right] = Screen10
  end
  
  def setup
    EnemySpirit.create(:x => 100)
    EnemySpirit.create(:x => 200)
    EnemySpirit.create(:x => 300)
  end  
end
