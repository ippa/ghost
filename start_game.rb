#
# 
#
require 'rubygems' unless RUBY_VERSION =~ /1\.9/
require 'gosu'      # www.libgosu.org - 2D ruby/c++ opengl accerated game framework
require 'texplay'

#
# Always load gem if we're packing Win32 EXE with Ocra.
# Otherwise:
# Try to load a local version of Chingu. On fail, load the rubygem.
#
if defined?(Ocra)
  require 'chingu'
else
  begin
    require 'chingu'
    #require '../chingu/lib/chingu'
  rescue LoadError
    require 'chingu'
  end
end

$: << File.join(ROOT,"lib")
ENV['PATH'] = File.join(ROOT,"lib") + ";" + ENV['PATH']

include Gosu
include Chingu

require_all File.join(ROOT, "src")

#exit if defined?(Ocra)

class Game < Chingu::Window
  attr_accessor :achievements, :firepower
  
  def initialize
    super(800, 600)
    self.input = { :esc => :close }
    self.caption = "Ghost! A mini-LD entry ~~ http://ippa.se/gaming ~~ (C) ippa 2009"
    
    @achievements = []
    @firepower = 1
    
    switch_game_state(Alive1.new)
    ## switch_game_state(Screen2.new)
    ## switch_game_state(Hell.new)
  end

end

Game.new.show
