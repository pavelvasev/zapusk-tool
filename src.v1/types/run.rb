# experimental!
# purpose: execute script code
# arguments:
# * lang
# * command1, command2, ...
# after execution, evaluation is passed to the next statement

module DasPerformRun

  def perform_type_run( vars, nxt )
    log "perform_type_rb: invoked with cmd=#{cmd}, subcomponent.name=#{vars['name']}"

    code = vars[ self.cmd ] || vars[ "default" ]

    if !code
      log "perform_type_run: record for cmd #{self.cmd} not found, passing to next statement (if any)"
      return perform_expression( nxt )
    end

    script = File.join(self.state_dir,"script-#{self.cmd}")
    
    File.open( script,"w" ) do |f|
      if code =~ /^#!/
        # code contains #!... mark, we will not add any ours
      else
        lang = vars[ "lang" ] || "bash"
        f.puts "#!/usr/bin/env #{lang}"
      end
      f.puts code
    end
    File.chmod( 0755, script )
    
    res = subos_system( script )
    
    if res == :ok
      perform_expression( nxt )
    else
      res
    end
  end

end

Zapusk.prepend DasPerformRun
