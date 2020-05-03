module DasPerformZdb

  attr_accessor :expression_args

  def perform_type_zdb( vars, nxt )
    zdb_type = vars["type"] ##|| component[:name] # todo вынести на уровень загрузки может?
    log "perform_type_zdb: type=#{zdb_type}"
    log "btw vars=#{vars.inspect}"
    log "vtw nxt=#{nxt.inspect}"
    zdb_path = find_zdb_path_e( zdb_type )
    do_perform_zdb( zdb_path, vars, nxt )
  end

  def do_perform_zdb( path, vars, nxt )
    # эта вещь может быть частью выражения
    # пока у нас принято что в выражении выполняется только 1 тип..
    # но идея сделать join все еще жива
    if vars["_component_name"]
      #log "ZDB: assigning #{vars['_component_name']} instead of #{vars['name']}"
      vars["name"] = vars["_component_name"] 
    end
    
  
    z = Zapusk.new
    z.dir = path
    # z.name = vars["_component_name"] || vars["name"]  
    # очень тонкий момент - мы присваиваем этому слою даже не свое имя, а имя компоненты
    # ибо считается в целом. что zdb-субэлемент в выражении может быть 1 штука максимум.
    # если этого не делать, то пойдет рассогласование..
    # хотя опять же формально.. может их проще скатенировать да и все
    #z.name = [vars["_component_name"],vars["name"]].compact.join("-")
    z.name = vars["name"]
    z.parent = self
    z.cmd = self.cmd
    z.external_params = vars.dup # ( {"state_dir" => state_dir} ) если это оверрайдит - то проще уж напрямую передать..
    z.external_params["parent_global_name"] = self.global_name
    z.external_params["component_global_name"] = z.global_name
    z.external_params["stack_of_types_dirs"] = [self.params["stack_of_types_dirs"], self.dir].compact.join(":")

    for k in self.params.keys do
      splitted = k.split("/")
      if splitted.length > 1 && (splitted[0] == z.name || splitted[0] == "*")
        newname = splitted[1..-1].join("/")
        z.external_params[ newname ] = self.params[k]
        log "passing /-param value to subz: #{newname} = #{self.params[k]}"
      end
    end

    # возможно,у вызова этой субкомпоненты zdb-типа есть nxt-секция
    # либо у нашего текущего типа уже  есть nxt секция - это все надо передать
    # todo подумать, может это все-таки arg1 ?
    if nxt.length > 0
      # чето я решил все подвычислить.. и типы им.. ну ладно..
      computed = nxt.map { |co|
        co2 = compute_subcomponent_vars( co )
        if !co2["type_dir"]
          co2["type_dir"] = find_zdb_path_e( co2["type"] )
        end
        if !co2["global_name"]
          co2["global_name"] = self.global_name + "-" + co2["name"]
        end
        co2
      }
      # первый субмпопонент вычислить надо - я так решил - хотя по уму все бы вычислить..
#      nxt[0] = compute_subcomponent_vars( nxt[0] )
      # ну и это, того..
#      for k in nxt do
#        if !k["type_dir"]
#          k["type_dir"] = find_zdb_path_e( k["type"] )
#        end
#      end
      z.expression_args = computed
      # теперь файлы.. формально это надо делать в стейт
      counter=0
      acc = []
      for a in z.expression_args do
        nama="arg_#{counter}.ini"
        z.state_files[nama] = { "content" => { "sections" => [a] } }
        acc.push(nama)
        counter=counter+1
      end
      # todo возможно надо сохранять не каждый раз, а только поступившие в nxt аргументе
      # а старые накапливать в arg_files полные пути
      z.external_params["arg_files"] = acc.join(" ")
    end

    #log "UUUUUUUUUUUUU before init, my name: #{z.name}"
    z.init_from_dir
    #z.log z
    #z.log z.dump_components
    
    if !["destroy","remove_removed"].include?(self.cmd)
      set_component_created_flag( z.name )
    end
    #log "UUUUUUUUUUUUU just set created flag for: #{z.name}"
    
    res = component_zapusk_perform( z )
    
    if ["destroy"].include?(self.cmd)
      unset_component_created_flag( z.name ) if is_component_created_flag( z.name )
    end
    
    res
  end

  def component_zapusk_perform( z ) # hooked by others
    z.perform
  end
  
    def find_zdb_path_e( zdb_type )
      lookup = [ self.dir ].concat( self.zdb_lookup_dirs )
      zdb_path = find_zdb_path( zdb_type,lookup )
      if zdb_path.nil?
        raise "perform_type_zdb: cannot find zdb of type `#{zdb_type}`! lookup dirs: #{lookup}"
      end
      zdb_path
    end  
  
  def find_zdb_path( zdb_type,lookup )
    for d in lookup do
      k = is_zdb_dir?( d,zdb_type+".zdb" )
      if k
        return k
      end
    end
    nil
  end
  
  def is_zdb_dir?( dir,subdir )
    path = File.join( dir, subdir )
    if File.directory?( path )
      return path
    end
    nil
  end

end

Zapusk.prepend DasPerformZdb
