# aim: configure Zapusk instance using zapusk.conf

# important to have priority more than state_manage, see prepare_state_dir override.

module DasZapuskConf

  def init_from_zapusk_conf( pf )
    # pf = File.join( self.dir, "zapusk.conf" )
    log "init_from_zapusk_conf: reading zapusk config #{pf}"
    if !File.exist?(pf)
#      raise "init_from_zapusk_params: zapusk.conf file not found!"
      log "init_from_zapusk_conf: zapusk.conf file not found!"
      return
    end
    
    p = read_params_file( pf )
    s = p["state_dir"] || raise("init_from_zapusk_conf: state_dir value is not specified!")
    import_state_from_params( p )
    
    if self.use_state_params
      state_params_file = File.join( p["state_dir"], "params.txt" )
      self.external_params = read_params_file( state_params_file )
      log "assigned own external params to values from file #{state_params_file}"
    end
  end
  
  # (dirname, basedir) -> выровненный dirname
  def param_dir( s, basedir )
    if s[0] == "." || s[0] != "/"
        s = File.join( basedir, s ) # use old dir value for that.. before reading new one..
      end
    s = File.expand_path( s )
  end
  
  def import_state_from_params( p )
    # log "import_state_from_params: p=#{p.inspect}"
    if p["state_dir"]
      s = p["state_dir"]
      s = param_dir( s, self.dir )
      self.state_dir = s
    end

    if p["zdb_dir"] && p["zdb_dir"] != self.dir
      olddir = self.dir
      self.dir = p["zdb_dir"]
      log "import_state_from_params: ZDB DIRECTORY WAS CHANGED TO #{self.dir} from #{olddir}" if olddir
    end
    
    if p["name"]
      self.name = p["name"]
    end
    
    if p["global_prefix"]
      self.global_prefix = p["global_prefix"]
    end    
    
    if p["global_name"] && p["global_name"] != self.global_name
       #self.global_name = p["global_name"]
       orig =  self.global_name
       origprefix = self.global_prefix
       self.global_name_override = p["global_name"]
       self.global_prefix = ""
       self.name = self.global_name_override
       #self.global_name_override
       # todo empty own global prefix?
       # todo assign own new name?? (to global name) ?
       #self.global_name_override # let all ancestors live inside this name?
       log "import_state_from_params: changed self global_name and global_prefix to '#{self.global_name_override}'. previous global_name was '#{orig}'. previous global_prefix was '#{origprefix}'"
       #log caller.join("\n")
    end
    
    if q=p["prepend_zdb_dirs"]
     arr = q.split(":")
     self.zdb_lookup_dirs = arr + self.zdb_lookup_dirs
    end
    
    if p["use_state_params"]
      self.use_state_params = true
    end

#   подождем пока.. если за это браться, то придется их еще и сохранять на каждом этапе..
#    if p["extra_libs"]
#      vals = p["extra_libs"].split(/":"/).map(&:chomp).delete_if{ |x| x.nil? && x.length == 0 }.map{ |x| param_dir( x, self.dir ) }
#      self.zdb_lookup_dirs = (vals + self.zdb_lookup_dirs).uniq
#    end
    
    #log "init_from_zapusk_params: using zdb dir #{self.dir} and state dir #{self.state_dir}"  
  end
  
  attr_accessor :use_state_params

end

Zapusk.prepend DasZapuskConf