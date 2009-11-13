class Enemy < GameObject
end

class EvilGhost < Enemy
  has_trait :collision_detection
  attr_reader :bounding_box
  
  def initialize(options)
    super
    @animation = Animation.new(:file => media_path("evil_ghost.bmp"), :size => [22, 20], :delay => 40)
    @bounding_box = Rect.new(@x, @y, 22, 20)
    self.rotation_center(:top_left)
    update
  end
  
  def update
    @image = @animation.next
  end
  
end