# feature: dump os command on command failure (useful!)
# feature: + dump workding dir on command failure (useful!)

module DasPerformBash

  # https://stackoverflow.com/a/16363159
  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  def subos_colors_begin
    "\e[32m"
  end
  
  def subos_colors_done
    "\e[0m"
  end
  
  def subos_command_options
    { "ZAPUSK_DEBUG" => (self.debug ? "--debug" : ""), "ZAPUSK_PADDING" => "#{self.padding}  ",
      "GEM_HOME" => nil, "GEM_PATH" => nil # feature: supress gem vars - because local ruby sets them, and foreign uses..
     }
    # todo force?
  end

  def perform_type_os( vars, nxt )
    log "perform_type_os: invoked with cmd=#{cmd}, subcomponent.name=#{vars['name']}"
    
    cmd = vars[ self.cmd ] || vars[ "default" ]
#    log "vars[ self.cmd ]=#{vars[ self.cmd ]}"
#    log "vars[ 'default' ]=#{vars[ 'default' ]}"
#    log "vars=#{vars.inspect}"
    
    if !cmd
      log "perform_type_os: record for cmd #{self.cmd} not found, skipping"
      return :ok_no_cmd_record
    end
    
    #cmd.gsub!( /^\.\//, self.dir )
     cmd.split(" ")[0]
    if cmd =~ /^(\S+)/
      script_file = $1
      if script_file[0] != "/" && script_file[0] != "."
        probable_full_path = File.join( File.expand_path( self.dir ), script_file )
#        log "checking full path for possible expand: #{probable_full_path}"
        if File.exist?( probable_full_path )
          cmd.gsub!( /^(\S+)/, probable_full_path )
        end
      end
    end
    
    #### save params.sh - might be used by sh programs
    write_params_file( File.join(self.state_dir,"params.sh"), self.params, true )
    
    log "perform_type_os: invoke cmdline=#{cmd}"
    res = subos_system( cmd )
    if res == :ok
      stop_expression( nxt )
    else
      res
    end
  end

  def subos_system( cmd )
    log "changing dir to: #{self.state_dir}"
    r = nil
    Dir.chdir( self.state_dir ) do
      
      print subos_colors_begin
      print "\n" if self.debug # доп \n нам нужен для более комфортного проведения тестов - грепить целые строчки
      opts = subos_command_options
      r = system( opts, cmd, :close_others => false )
      print subos_colors_done
      print "\n" if self.debug
    end
    
    if r.nil?
      raise "os command execution failed. cmd=[#{cmd}], pwd=[#{self.state_dir}]"
    elsif !r
      s = $?.exitstatus
      log "os command non-zero exit code! [#{s}]."
      if s == 100
        log "code 'stop' components computation"
        return :stop
      end
#      if s == 110
#        log "code 'continue_step' components computation"
#        return :contunue_step
#      end
#     * Если команда вернула код возврата 110, это считается запросом продолжить обработку следующих шагов в текущей компоненте вызывающего zdb-типа.
      raise "unsupported non-zero exit code [#{s}]. cmd=[#{cmd}], pwd=[#{self.state_dir}]"
    else
      log "perform_type_os: os command executed"
    end
    :ok
  end

end

Zapusk.prepend DasPerformBash
