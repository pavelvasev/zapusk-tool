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
      if deferred_master && File.exist?( k )
        h = read_params_file( k )
        File.unlink( k )
        log "deferred: found and calling deferred scripts. cmd=#{cmd}. keys=#{h.keys}"
        # info "found deferred: #{h.keys}"
        for n in h.keys do
          cmd = h[n]
          info "Run deferred script: #{cmd}"
          puts subos_colors_begin
          system( cmd )
          puts subos_colors_done
        end
        log "deferred: done"
      end
      r
    end
  end

end

Zapusk.prepend DasDeferred
