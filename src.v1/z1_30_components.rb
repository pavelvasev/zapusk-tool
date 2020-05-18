# aim: convert params (in zapusk language) into list of components
#      which are high level of representation of zapusk program
#      ready to be interpreted

module DasComponentsLoad

  def init_from_dir
    super
    load_components
  end

  def load_components
    self.comps = sections_to_components( self.own_body )
#    log "load_components. self.name=#{self.name}"
#    log "self.comps=#{self.comps.inspect}"
  end

  def sections_to_components( sections )
#    info "sections_to_components. self.name=#{self.name}"
#    info "sections_to_components: before converstion acc=#{sections.inspect}"

    acc = []
    for s in sections do

      if s["hilevel"]
        n = s["name"]
        autogenerate_lo_for_last_hi( acc )

        newhiname = n.strip.gsub( /[^\w\d\-_]/,"-" ).gsub(/(^-+|-+$)/,"")
        raise "hi-level component name is blank!" if newhiname.length == 0
        # new hi-order section
        hi = { "name" => newhiname, "sections" => [], "orig_keys" => s }
        acc.push hi
      else
        if acc.length == 0
          raise "params_to_components: second-level component without first-level component!"
        end
        cur_hi = acc.last
        s["_component_name"] = cur_hi["name"]
        s["type"] ||= s["name"]
        cur_hi["sections"].push s
      end
    end
    autogenerate_lo_for_last_hi( acc )

#    info "sections_to_components: after converstion acc=#{acc.inspect}"

    # after this transformation, we have an acc of structure:
    # [ hi, hi, hi, ... , hi]
    # where each hi is a hash with "name" and 2) "sections" key of structure:
    # some-hi["sections"] = [ lo, lo, lo, ... , lo]
    # where each lo is a component record with at least fields:
    # lo["name"], lo["type"], lo["_component_name"]
    # where _component_name is a name of hi-level section
    
    # note that each hi have at least 1 lo component inside self
    acc
  end
  
  # автоматическая генерация узла для компонента, в котором забыли указать узел
  def autogenerate_lo_for_last_hi( acc )
    return if acc.length == 0
    last_hi = acc.last
    if last_hi[ "sections" ].length == 0
       s = last_hi["orig_keys"]
       s["_component_name"] = s["name"] = last_hi["name"]
       s["type"] ||= s["name"]
       last_hi["sections"].push s
    end
    last_hi.delete( "orig_keys" )
    acc
  end
  
=begin   todo use in includes
  def eval_loads( sections )
    acc = []

    sections.each { |s|
#      info "eval_loads: s=#{s}"
      if s["name"].downcase == "load" # мб [ @@@@@ load @@@@@ ] ?
        # ok special case..
        path = s["path"] || "??-*.{txt,ini}"
        if is_path_relative( path )
          path = File.join( self.dir, path )
        end
        Dir.glob(path).sort.each do |f|
#          log "load: #{f}"
          k = read_params_file( f )
          name_with_priority = File.basename(f, File.extname(f) )
          # extract name part
          name = if name_with_priority =~ /(\w\w)-(.+)/
            $2
          else
            name_with_priority
          end

          if k["sections"] && k["sections"].length > 0 && k["sections"][0]["name"] =~ /\*\*+/
            # there is a hi-level section
          else
            # there is no hi-level section - create it
            q = k.dup
            q["name"] ||= name
            q["name"] = "****** #{q['name']} ******* " # convert to hi-level
            q.delete("sections")
            acc.push q # by the way, we save all original params of that k here
          end
          loaded_sections = k["sections"].is_a?(Array) ? k["sections"] : []
          loaded_sections = eval_loads( loaded_sections )
          acc = acc.concat( loaded_sections ) # todo optimize
        end
      else
        acc.push s
      end
    }
    # after this transformation, all [load] sections are transformed
    # into hi-level sections representing files loaded by that load
    
#    log "load: after transofrm, sections=#{acc}"
    
    acc
  end  
=end  

  def dump_components
    "components: " + self.comps.inspect
  end

  def compute_subcomponent_vars( vars, testmask=nil )
     log "compute_subcomponent_vars: vars=#{vars.inspect}"
     knowledge = self.params.merge( { "cmd" => self.cmd } )
     compute_params( vars, knowledge, "subcomponent #{vars['name']}", testmask )
  end

end

Zapusk.prepend DasComponentsLoad
