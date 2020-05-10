# предназначение: предоставить возможность выполняить отложенные действия, причем сгруппированные по ключам
# например таким образом можно не перезагружать нжинкс 10 раз

# использование - в глубинах выполнения скрипты должны писать в ENV["ZAPUSK_DEFERRED_PATH"] в ини-формате
# записи вида
# uniq-code = command line

module DasDeferred

  def perform
    k = ENV["ZAPUSK_DEFERRED_PATH"]
    deferred_master = (k.nil? || k == "") ? true : false
    if deferred_master
      ENV["ZAPUSK_DEFERRED_PATH"] = File.expand_path( File.join( self.state_dir,"deferred.ini" ) )
    end
    r = nil
    begin
      r = super
    ensure
      k = ENV['ZAPUSK_DEFERRED_PATH']
      if deferred_master 
        count=0
        # дефер-задачи могут еще повторно создавать дефер-задачи
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
        log "deferred: done"
      end
      r
    end
  end

end

Zapusk.prepend DasDeferred
