# aim: manage state of sub-components of current zapusk component

# btw:
#   * create state dir for current component
#   * track created sub-components
#   * remove deployed sub-components which were then deleted by user


require "fileutils"

module DasStateManage

  attr_accessor :state_files
 
  def initialize
    super
    self.state_files ||= {}
  end

  def perform
    remove_removed_components

    if self.cmd == "destroy" || self.cmd == "remove_removed"
      if File.exist?( self.state_dir )
        r = super
        move_collapsed_self_state_dir
        return :done_destroyed
      end
      log "state_dir not exist: #{self.state_dir}"
      return :noneed_state_dir_not_exist
    end

    prepare_state_dir
    super
  end
  
  def move_collapsed_self_state_dir
    # remove self state dir
    backup_dir = File.expand_path( File.join( self.state_dir,"..","_zapusk.removed" ) )
    collapse_state_dir( self.state_dir, backup_dir )
  end
 

  def prepare_state_dir

    FileUtils.mkpath( self.state_dir )

    sf = self.state_files || {}

    sf["params.txt"] = { "content" => self.params }
    # sf["params.sh"] = { "content" => self.params, "escaping" => true }
    sf["zapusk.conf"] = { "content" => self.zapusk_params.merge({"use_state_params"=>1}) }

#    if self.expression_args && self.expression_args.length > 0
#      sf["args.ini"] = { "content" => { "sections" => self.expression_args } }
#    end

    for k in sf.keys
      content = sf[k]["content"]
      write_params_file( File.join(self.state_dir,k), content, sf[k]["escaping"] )
    end
  end

  # purpose: find directories in state dir which does not correspond to zdb combonents
  # ant treat them as old, removed components, and collapse them
  def remove_removed_components
    comps_names = {}
    self.comps.each { |c| comps_names[ c["name"] ] = 1 }

    backup_dir = File.join( self.state_dir,"_removed" )

    Dir.glob( File.join( components_created_flags_dir,"*" )).each do |r|
#      log "remove_removed: testing #{r}"
      next if !File.file?(r)
      name = File.basename( r )
      
      r =~ /^(.+)_zapusk.created/
      desired_state_dir = "#{$1}/#{name}"
      if !File.directory?( desired_state_dir )
        log "remove_removed_components: I see created component flag, but no state dir. Strange!!!!!!!!!!!!!!!!!!!!"
        log "remove_removed_components: flag_file=#{r}"
        next
        ## unset_component_created_flag( name )
      end
      # todo добавить проверку наличия файла params.txt - но лучше файла params просто, без txt
#      log "checking in compnames"
      
      if !comps_names[ name ]
        log "remove_removed_components: see existing flag and state dir [#{name}], but no component record - removing it."
        log "remove_removed_components: flag_file=#{r}"
        collapse_component( desired_state_dir,backup_dir )
        unset_component_created_flag( name )
      end
    end
  end
  
  ##################################################################

  def components_created_flags_dir
    File.join( self.state_dir,"_zapusk.created")
  end
  
  def set_component_created_flag( name )
    log "set_component_created_flag: name=#{name}"
    fd = components_created_flags_dir
    fn = File.join(fd,name )
    FileUtils.makedirs( fd )
    File.open( fn,"w" ) { |f| f.puts Time.now }
  end

  def unset_component_created_flag( name )
    fd = components_created_flags_dir
    fn = File.join(fd,name )
    File.unlink(fn)
  end
  
  def is_component_created_flag( name )
    fd = components_created_flags_dir
    fn = File.join(fd,name )
    File.exist?(fn)
  end

  def collapse_component( state_path, backup_dir )
    z = Zapusk.new
    z.dir = state_path

    zconf = File.join( state_path, "zapusk.conf" )
    z.init_from_zapusk_conf( zconf ) # by the way this will set 'use_state_params' flag.
    if File.expand_path(z.dir) == File.expand_path(state_path)
      raise "collapse_component: zdb dir must be differed from state dir! This is not true after reading #{zconf}"
    end
    if ! File.directory?( z.dir )
      warning "collapse_component: component directory does not exist! dir=#{z.dir}"
      return
    end
    z.parent = self
    track_stack(z) do

    # we need to get params from state
    # because vars from these params may be used in computations
    # in own params of component..
    state_params_file = File.join( state_path, "params.txt" )
    z.external_params = read_params_file( state_params_file )
    z.init_from_dir
    z.cmd = "destroy"
    z.perform
    end # track stack

    # component itself will issue it's own collapse_state_dir call
    # collapse_state_dir( state_path, backup_dir )
  end

  def collapse_state_dir( state_path, backup_dir )
    s = File.basename( state_path )
    backup_path = File.join( backup_dir,"#{s}.at_#{Time.now.to_i}" )
    log "collapse_state_dir: moving dir #{state_path} to #{backup_path}"
    FileUtils.makedirs( backup_path )
    FileUtils.mv( state_path, backup_path )
  end

end

Zapusk.prepend DasStateManage