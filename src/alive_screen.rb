class Alive1 < Chingu::GameState
  def initialize(options = {})
    super
    
    @truck = GameObject.create(:x => $window.width, :y => $window.height-70, :image => Image["truck.png"], :rotation_center => :left_bottom)
    @truck_endpoint = $window.width - 150
    @player_hit = false

    @background = GameObject.create(:image => "screen1_alive.png", :zorder => 10)
    @background.rotation_center(:top_left)

    @player = AlivePlayer.create(:x => 330, :y => 500, :zorder => 100)
    @sky1 = Color.new(0xFFACFFEC)
    @sky2 = Color.new(0xFF0012FF)         
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
        
    if @player.x > @truck_endpoint && @truck.x > @truck_endpoint
      Sound["skid.ogg"].play  if @truck.x == $window.width
      
      @truck.x -= 10
    end
    
    if @truck.x <= @truck_endpoint && @player_hit == false
      Sound["hit.wav"].play
      
      @player_hit = true
      @player.velocity_x  = -10
      @player.velocity_y  = -10
      @player.rotation_rate = 8
    end
    
    switch_game_state(Funeral) if @player.outside_window?
  end
  
  def draw
    fill_gradient(:from => @sky2, :to => @sky1, :zorder => -1)    
    super
  end
  
end


class Funeral < GameState
  has_trait :timer
  
  def setup
    Song["church.ogg"].play
    after(6000) { push_game_state(GameStates::FadeTo.new(Screen1, :speed => 2)) }
    GameObject.create(:x => $window.width/2, :y => $window.height/2, :image => "rip.png", :rotation_center => :center)
  end  
  
end
