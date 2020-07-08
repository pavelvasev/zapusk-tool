# aim: load zapusk.default.conf

# effect: merge it within global_conf provided by zapusk_global_conf

module DasZapuskConfDefault

  attr_accessor :global_conf
  
  def load_global_conf
    super
    
    fn = File.join( Zapusk::TOOL_DIR,"zapusk.tool-defaults.conf" )
    if File.exist?(fn)
      defaults = read_params_file( fn )
      
      self.global_conf = defaults.merge( self.global_conf || {} )
    end

  end

end

Zapusk.prepend DasZapuskConfDefault
