module DasZapuskConfGlobale

  attr_accessor :global_conf
  
  def load_global_conf
    fn = File.join( Zapusk::TOOL_DIR,"zapusk.global.conf" )
    if File.exist?(fn)
      self.global_conf = read_params_file( fn )
    end
  end

end

Zapusk.prepend DasZapuskConfGlobale
