# aim: provide global_name computation

module DasGlobalName

  attr_accessor :global_name_override
  
  def global_name
    self.global_name_override || begin
      a=self.global_prefix.length > 0 ? File.join( self.global_prefix, self.name ) : self.name
      #a.gsub!(/[^\w-]/,"_") - this variant keeps -
      #a.gsub!(/[^\w]/,"_")
      #a.gsub!(/^_+/,"")
      a.gsub!(/[^\w]/,"-")
      a.gsub!(/^-+/,"")
      a
    end
  end
  
  def global_path
    self.global_name_override || begin
      a=self.global_prefix.length > 0 ? File.join( self.global_prefix, self.name ) : self.name
    end
  end

end

Zapusk.prepend DasGlobalName