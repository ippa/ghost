#
# 
#
require 'rubygems'
require 'gosu'      # www.libgosu.org - 2D ruby/c++ opengl accerated game framework
require 'texplay'

#
# Try to load a local version of Chingu. On fail, load the rubygem.
#
begin
  require '../chingu/lib/chingu'
rescue LoadError
  require 'chingu'
end

include Gosu
include Chingu

require_all 'src/'

class Game < Chingu::Window
  attr_accessor :achievements, :firepower
  
  def initialize
    super(800, 600)
    self.input = { :esc => :close }
    self.caption = "Ghost! A mini-LD entry. http://ippa.se/gaming"
    
    @achievements = []
    @firepower = 1
    
    # switch_game_state(Screen1.new)
    switch_game_state(Hell.new)
    
    ## switch_game_state(Alive1.new)
  end

end

Game.new.show