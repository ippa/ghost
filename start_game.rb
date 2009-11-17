#
# 
#
GAMEROOT = File.dirname(File.expand_path($0))
$: << File.join(GAMEROOT,"lib")
ENV['PATH'] = File.join(GAMEROOT,"lib") + ";" + ENV['PATH']

require 'rubygems' unless RUBY_VERSION =~ /1\.9/
require 'gosu'      # www.libgosu.org - 2D ruby/c++ opengl accerated game framework
require 'texplay'

#
# Try to load a local version of Chingu. On fail, load the rubygem.
#
require 'chingu'
#begin
#  require '../chingu/lib/chingu'
#rescue LoadError
#  require 'chingu'
#end

include Gosu
include Chingu

require_all File.join(GAMEROOT, "src")

exit if defined?(Ocra)

class Game < Chingu::Window
  attr_accessor :achievements, :firepower
  
  def initialize
    super(800, 600)
    self.input = { :esc => :close }
    self.caption = "Ghost! A mini-LD entry ~~ http://ippa.se/gaming ~~ (C) ippa 2009"
    
    @achievements = []
    @firepower = 1
    
    switch_game_state(Alive1.new)
    ##switch_game_state(Screen15.new)
    ## switch_game_state(Hell.new)
  end

end

Game.new.show
