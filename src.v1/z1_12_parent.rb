# aim: provide parent= method so configuring child zapusk instances will be easier

module DasMainParent
  attr_accessor :parent

  def parent=(p)
    @parent = p

    raise "self name should be not blank, at the moment of assigning parent!" if self.name.nil?

    self.debug = p.debug
    # todo вынести дебуг в отдельный слой нафиг

    self.zdb_lookup_dirs = p.zdb_lookup_dirs
    self.global_conf = p.global_conf
    
    # новое:
    self.global_prefix = p.global_name # parent_global_name?
    
    # до 18-05-2020:
    # self.global_prefix = File.join( p.global_prefix, p.name )
    
    # log "do_perform_zdb assigned global_prefix to subz = #{z.global_prefix}. self.global_prefix=#{self.global_prefix}"
    self.state_dir = File.join( p.state_dir, self.name )

    p
  end

end

Zapusk.prepend DasMainParent