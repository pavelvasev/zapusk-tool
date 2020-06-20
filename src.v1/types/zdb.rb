module DasPerformZdb

  attr_accessor :expression_args

  def perform_type_zdb( vars, nxt )
    zdb_type = vars["type"] ##|| component[:name] # todo вынести на уровень загрузки может?
    log "perform_type_zdb: type=#{zdb_type}"
    log "btw vars=#{vars.inspect}"
    log "vtw nxt=#{nxt.inspect}"
    zdb_path = find_zdb_path_e( vars )
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
    res = nil
    
    track_stack( z ) do
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
          co2["type_dir"] = find_zdb_path_e( co2 )
        end
        if !co2["global_name"]
          # тэкс. на уровне [] global_name не задано
          # первая идея - ну просто взять наше global name, и приплюсовать их имя 
          # но выяснилось что я хочу - задавать global_name на уровне типа
          
          co2z = Zapusk.new
          co2z.dir = co2["type_dir"]
          co2z.name = co2["name"]
          co2z.parent = self
          co2z.external_params = co2
          co2z.init_from_dir
          
          # вот это еще больший хак, проверка на main
          # но так уж повелось, что у chroot-типов я пишу main, и они уже развернуты
          # а формально, вроде как, надо все-таки чтобы был учет текущей компоненты.. ну надо.. это некий scope, чистой воды..
          # и второй хак - что имя компоненты не равно имени шага, а то какая-то тафталогия получается..
          if vars["name"] != "main" && vars["name"] != co2["name"]
            co2z.global_prefix = self.global_name + "-" + vars["name"] # это хак, но без него и вовсе глупость выходит
          end
          # todo добавить защиту от дублирования имен компонент. но пока это активно юзается только в employ
          # а там валится ошибка если тчо
          
          # ибо получается что мы prefix задаем - наше global_name, а оно относится ко всей программе, а не к текущему блоку
          # и т.о. мы восстановили как бы справедливость
          # единственное что - возможно надо не vars["name"] читать, а _component_name все-таки
          
          co2["global_name"] = co2z.global_name # или прочтется из определения типа, или будет формула
          #info( "co2 assigned global name ="+co2["global_name"]+", btw self global_name="+self.global_name+"and vars[name]="+vars["name"] )
  
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
    end # track stack

#    if res == :continue_step
#      res =  if nxt.length > 0
#         perform_expression( nxt )
#      else
#         :done
#      end
#    end

    res
  end

  def component_zapusk_perform( z ) # hooked by others
    z.perform
  end
  
    def find_zdb_path_e( vars )
      zdb_type = vars["type"]
      
      # если указали напрямую - пожалуйста, мы не против
      td =  vars["type_dir"]
      return td if td && File.directory?( td )
      
      # поищем в каталогах..
      lookup = [ self.dir ].concat( self.zdb_lookup_dirs )
      zdb_path = find_zdb_path( zdb_type,lookup )
      if zdb_path.nil?
        raise "perform_type_zdb: cannot find zdb of type `#{zdb_type}`! lookup dirs: #{lookup}"
      end
      zdb_path
    end  
  
  def find_zdb_path( zdb_type,lookup )
    # посмотреть в каталогах lookup
    for d in lookup do
      k = is_zdb_dir?( d,zdb_type+".zdb" )
      if k
        return k
      end
    end
    # посмотреть на 1 уровень ниже в этих же каталогах
    for d in lookup do
      Dir.glob( File.join( d,"*" ) ).sort.each do |p|
        if File.directory?(p) && p !~ /\.zdb/i
          k = is_zdb_dir?( p,zdb_type+".zdb" )
          if k
            return k
          end
        end
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
