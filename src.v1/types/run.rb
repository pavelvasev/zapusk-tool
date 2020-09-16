# experimental!
# purpose: execute script code
# arguments:
# * lang
# * command1, command2, ...
# after execution, evaluation is passed to the next statement

# THINK: currently [run] are spawned as subprocesses
# probably better to think of them as a code spawned in a special envelope?
# say to access params...

# THINK: we save a lot of versions of params (sh, yaml, json..) do we need them?
# maybe better to provide converters from text to these formats?...

#require "yaml"
require "json"

module DasPerformRun

  def perform_type_run( vars, nxt )
    log "perform_type_rb: invoked with cmd=#{cmd}, subcomponent.name=#{vars['name']}"

    code = vars[ self.cmd ] || vars[ "default" ]

    if !code
      log "perform_type_run: record for cmd #{self.cmd} not found, passing to next statement (if any)"
      return perform_expression( nxt )
    end
    
    ####### save params  in sh, yaml, json format

    write_params_file( File.join(self.state_dir,"params.sh"), self.params, true )
#    File.open( File.join(self.state_dir,"params.yaml"), "w" ) do |f|
#      f.puts self.params.to_yaml
#    end
# do we need json at all?
    File.open( File.join(self.state_dir,"params.json"), "w" ) do |f|
      f.puts self.params.to_json
    end

    ####### save code
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
