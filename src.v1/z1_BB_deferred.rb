# aim: provide deferred computation ability

# usage:
#  every zapusk component may add lines to a deferred file $ZAPUSK_DEFERRED_PATH in format:
#  key-name1 = command1
#  key-name2 = command2
#  After zapusk-tool computes all tasks, it parses deferred file and calls commands specified in it
#  In case of duplicates in keynames, only one command is called (last command has higher priority)

#  In case of new commands in deferred file are added during computation of deferred commands, 
#  the above algorythm is repeated up to N=10 times.

module DasDeferred

  def perform
    k = ENV["ZAPUSK_DEFERRED_PATH"]
    deferred_master = (k.nil? || k == "") ? true : false
    if deferred_master
      ENV["ZAPUSK_DEFERRED_PATH"] = File.expand_path( File.join( self.state_dir,"deferred.ini" ) )
    end
    r = super
    run_deferred_things
    r
#    begin
#      r = super
#    ensure
#      r
#    end
  end
  
  def run_deferred_things
    k = ENV['ZAPUSK_DEFERRED_PATH']
    if deferred_master
        count=0
        # deferered tasks may create new deferred tasks
        while File.exist?( k )
          h = read_params_file( k )
          File.unlink( k )
          log "deferred: found and calling deferred scripts. cmd=#{cmd}. keys=#{h.keys}"
          # info "found deferred: #{h.keys}"
          for n in h.keys do
            cmd = h[n]
            info "Run deferred script: #{cmd}"
            puts subos_colors_begin
            r = system( subos_command_options, cmd )
            puts subos_colors_done
            
            if r.nil?
	      raise "os command execution failed. cmd was `#{cmd}`"
	    elsif !r
	      s = $?.exitstatus
	      log "os command non-zero exit code! [#{s}]"
	      if s == 100
	        log "code 'stop' components computation"
	        break
	      end
	      raise "unsupported non-zero exit code [#{s}]"
            end
          end # for
            
          count=count+1
          if count >= 10
            warning "stopped deferred loop, >= 10 iterations!"
          end
      end
      log "deferred: all done"  
    end
  end

end

Zapusk.prepend DasDeferred
