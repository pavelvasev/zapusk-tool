module DasMain
  attr_accessor :dir
  attr_accessor :cmd
  attr_accessor :comps
  attr_accessor :zdb_lookup_dirs
  attr_accessor :name
  attr_accessor :global_prefix
  attr_accessor :state_dir
  
#  def global_prefix=(v)
#    log "!!! assigned global_prefix = #{v}"
#    log caller.join("\n")
#    @global_prefix=v
#  end
  
  def initialize
    self.dir="."
    self.zdb_lookup_dirs = []
    self.global_prefix = ""
  end

  def to_s
    "zapusk: dir=#{self.dir}, cmd=#{self.cmd}, name=#{self.name}, state_dir=#{self.state_dir}"
  end

  def ready?
    if comps.length == 0
      warning "ready?: empty components list! this is not error, just warning!"
      info    "ready?: dir=#{self.dir}"
    end
    raise "ready?: zdb dir file test failed, is not a directory! dir=#{dir}" if !File.directory?(dir)
    raise "ready?: components not loaded!" if comps.nil?
    raise "ready?: cmd in invalid format! cmd=#{self.cmd}" if self.cmd.nil? || self.cmd !~ /^[\w_-]+$/ # multiline??
    raise "ready?: name is not assigned!" if self.name.nil?
    raise "ready?: state_dir is not assigned!" if self.state_dir.nil?
    raise "ready?: state_dir too short!" if File.expand_path(self.state_dir).length < 4
    if comps.length > 0 # пусть отсутствие глоб имени будет ошибкой только при наличии компонент
      raise "ready?: global_name length is 0!" if self.global_name.length == 0 
    end
    true
  end

  def init_from_dir
  end

end

Zapusk.prepend DasMain