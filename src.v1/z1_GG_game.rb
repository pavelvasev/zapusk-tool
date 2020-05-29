################################################################
# aim: game for user

module DasGamingGaming

  def report_game
    v = game_results
    s = v[0..-2].join(", ") + " and #{v[-1]}."
    #s = v.join(".")
    info "Achievements: #{s}"
    
    count=1
    extra = game_results_extra
    if extra.length == 1
      info extra[0]
    else
      for k in extra do
        #s = s + "\n#{count}. #{k}"
        info "#{count}. #{k}"
        count=count+1
      end
    end
  end
  
  def game_results
    []
  end
  
  def game_results_extra
    []
  end

end

Zapusk.prepend DasGamingGaming

################################################################
# aim: exception game for user

require 'benchmark'

module DasExceptionGame

  def game_results
    if self.exception_title
      ["1 error"]
    else
      []
    end + super
  end
  
  def game_results_extra
    if self.exception_title
      ["ERROR: "+self.exception_title]
#      []
    else
      []
    end + super
  end
  
  attr_accessor :exception_title

end

Zapusk.prepend DasExceptionGame

################################################################
# aim: warnings game for user

require 'benchmark'

module DasWarningsGame

  attr_accessor :warnings
  
  def initialize
    self.warnings=[]
    super
  end

  def warning( msg )
    keep_warning( msg )
    super
  end
  
  def keep_warning( msg )
    if self.parent
      self.parent.keep_warning( msg )
    else
      #self.warnings ||= []
      self.warnings.push( msg )
    end
  end
  
  def game_results
    ["#{self.warnings.length} warnings"] + super
  end
  
  def game_results_extra
    self.warnings + super
  end

end

Zapusk.prepend DasWarningsGame

################################################################
# aim: warnings game for user

require 'benchmark'

module DasTimingsGame

  attr_accessor :perform_time

  def perform
    r = nil
    self.perform_time = Benchmark.realtime do
      r = super
    end
    r
  end
  
  def game_results
    ["runtime #{sprintf('%0.3f',self.perform_time || 0)} seconds"] + super
  end

end

Zapusk.prepend DasTimingsGame

################################################################