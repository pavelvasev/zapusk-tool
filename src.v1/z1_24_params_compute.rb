# aim: provide computatation abilities for param values, e.g.
# * replace `{{ paramname }}` entries with value of `paramname`
# * replace `{\` os-command \`}` with os-command standard output

# main function is **compute_params**: params -> computed_params

# надо для caputure
require "open3"

module DasParamsCompute

  def compute_params( params, extra_know, error_msg_context,testmask=nil )
    newh = {}
#    puts params.inspect
    for k in params.keys do
#      puts "k=#{k}, params[k]=#{params[k]}"
      next if testmask && !testmask.match(k) # вообще тестовая маска нам нужна, чтобы по 5 раз одно и то же не вычислять - мы вызываем compute_component_vars 2 раза ибо
      newh[k] = compute_param_value( params[k], params, extra_know, error_msg_context, { k=>1 },testmask )
#      puts "newh[k]=#{newh[k]}"
    end
    newh
  end
  
  def compute_param_value( str, dict, extra_dict, msg, already_computing,mask )
#    log "CPV: str=#{str}, msg=#{msg}"
    # if value is a hash - compute it's keys..
#   _component  у нас недает нам хеш считать    
#    if str.is_a?(Hash)
#      return compute_params( str, extra_dict, msg, mask )
#    end
    # если это массив - то поэлементный расчет произвести
    # рассчитываю что это будут разделы (sections)
    # но опять же - теперь массив покусочно рассчитывается, так что это вроде как и не надо
    # TODO см см см.. возможно ни хеши, ни массивы не надо считать
    if str.is_a?(Array)
      return str
      # новое веяние - нефиг массивы рассчитывать. ибо у нас в массивах только sections сидят. 
      # а они рассчитываются отдельно см compute_subcomponent_..
      # и более того, их вредно рассчитывать заранее - у них значения переменных могут поменяться 
      # (например верхний субкомпонент заменит cmd)
      acc = []
      for a in str do
        r = compute_params( a, extra_dict, msg, mask )
        acc.push r
      end
      return acc
    end
    return str if !str.respond_to?(:gsub) # not a string..
    # vars
    str = str.gsub( /{{([^}]+)}}/ ) do |match|
      name = $1.strip
      find_param_value( name, dict, extra_dict, msg, already_computing,mask )
    end
    
    # before os call, because I think os call may return anything and it will be valid
    check_value_for_possible_errors( str )
    
    # os
    str = str.gsub( /{`([^`]+)`}/ ) do |match| #`
      cmd = $1.strip
      env = subos_command_options
      # похоже единственный способ передать env в `` это вызвать Open3
      # а нам надо передать, чтобы GEM_HOME и проч. нормально были настроены
      # https://ruby-doc.org/stdlib-2.3.1/libdoc/open3/rdoc/Open3.html
      # + еще можно как в os, перейти в каталог.. Dir.chdir( self.state_dir ) do ... end
      # + но это надо будет закрепить в спецификации тогда 
      r,status = Open3.capture2( env, cmd )
      #r = `#{cmd}`
      #if $?.exitstatus != 0
      if status != 0
        raise "compute_param_value: {`...`}-os call returned non 0 exit code. cmd=#{cmd}"
      end
      # todo check 
      r.chomp
    end
    

    
    str
  end
  
  def check_value_for_possible_errors( str )
    if str =~ /{{([^}]+)}|{([^}]+)}}/
      warning "check value for {}-mismatch errors! [#{str}]"
    end
  end
  
  def find_param_value( name, dict, extra_dict, msg, already_computing,mask )
#      info "FPV: name=#{name}"
      if extra_dict[ name ]
#        log "used extra-dict: #{extra_dict[ name ]}"
        return extra_dict[ name ]
      end
      if already_computing[ name ]
        raise "find_param_value: cycle found while computing #{name} (#{msg})"
      end
      # r = dict[ name ] || extra_dict[ name ]
      r = dict[ name ]
      if r
#        log "used own-dict: #{dict[ name ]}"
        compute_param_value( r, dict, extra_dict, "#{msg} -> #{r}", already_computing.merge({ name => 1 }),mask )
      else
        raise "find_param_value: value for name=#{name} not found! #{msg}. dict=#{dict.inspect}, extra_dict=#{extra_dict.inspect}"
      end
  end

end

Zapusk.prepend DasParamsCompute