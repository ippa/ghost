class Fog < GameObject
  has_trait :velocity
  def initialize(options)
    super
    self.rotation_center(:top_left)
    @image = rand(5) < 4 ? Image["cloud.png"] : Image["cloud2.png"]
    @color.alpha = 5 + rand(15)
    @velocity_x = -rand/2 + rand/2
    self.factor = 1 + rand*2
  end
  
  def right
    @x + @image.width * @factor_x
  end
end


class PowerUp < GameObject
  has_trait :bounding_box
  attr_reader :type

  def initialize(options)
    super
    @type = options[:type] || 2
    
    @image = Image["power_up.png"]    if @type == 2
    @image = Image["power_up_2.png"]  if @type == 3
    
    self.rotation_center = :center
  end
  
end
