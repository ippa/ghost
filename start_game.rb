#
# 
#
require 'rubygems'
require 'opengl'
require 'gosu'
require 'texplay'

begin
  require '../chingu/lib/chingu'
rescue LoadError
  require 'chingu'
end

include Gosu
include Chingu

require_all 'src/'

class Game < Chingu::Window
  attr_reader :player
  
  def initialize
    super(800, 600)
    self.input = { :esc => :close }
    @player = Player.create(:x => 230, :y => 400, :zorder => 100)
    
    push_game_state(Screen1.new)
  end
end

Game.new.show