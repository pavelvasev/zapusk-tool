# Предназначение: создать файл с указанным содержимым по указанному пути

# например:
# [file]
# path=name.txt
# content=123

# например:
# [file]
# path=/etc/example-absolute-path.conf
# content="
# example
# multiline content
# "

require "fileutils"

module DasPerformFile

  def is_path_relative( path )
    path[0] == "." || path[0] != "/"
  end
  
  EMPTY_BACKUP_MARK="zapusk-file-empty-mark"

  # задача - восстановить файл path из backup_path если backup_path есть, и стереть если нет
  # при этом в файле backup_path может быть особая метка говорящая,
  #  что реально бэкапа нет и там было пусто

  def restore_or_erase!( path, backup_path )
    if File.exist?( backup_path )
      firstline = File.open( backup_path,"r") do |bf|
        bf.gets.chomp
      end
      if firstline == EMPTY_BACKUP_MARK
        File.unlink( backup_path )
        File.unlink( path ) if File.exist?( path )
        return
      end
      self.info "file: restoring backup [#{path}]"
      FileUtils.cp( backup_path, path )
      File.unlink( backup_path )
    else # иначе просто стираем
      File.unlink( path ) if File.exist?( path )
      log "file: deleted [#{path}] to restore state"
    end
  end

  # TODO - распутать эту вермишель
  # TODO - в этом коде есть косяк, он затирает файлы, см tests/50-featured-nodes/64-file-overwrite-change
  def perform_type_file( vars, nxt )
    if ! ["testing","apply","destroy"].include?(self.cmd)
      log "command is not apply nor destroy - skipping file operation."
      return stop_expression( nxt )
    end
  
    path = vars["path"] || raise("perform_type_file: path not specified")
    content = vars["content"] || ""
    # todo: может list на вход - список файлов?
    # info "performing file, #{vars.inspect}"
    
    if is_path_relative( path ) # relative
      path = File.join( self.state_dir, path )
    end
    
    # временный дикий хак (внедрение левого кода + двойная реализация)
    if self.cmd == "testing"
      if vars["testing"] != "false"
        construct = { "type" => "testing", "_component_name" => "testing",
          "code" => "check-file", "arg_path" => path, "comment" => "файл должен присутствовать" }
      
        if mode = vars["mode"]
          construct["arg_mode"] = vars["mode"]
          " и иметь права #{mode}"
        else
          ""
        end
        perform_expression( [construct] )
        #info "TESTING:#{ENV['ZAPUSK_TESTING_CONTEXT']} файл должен присутствовать path=#{path}#{s}"
        #info "TESTING: файл должен присутствовать path=#{path}#{s} # via #{self.global_name}"
        #info "TESTING: файл должен присутствовать path=#{path}#{s}"
      end
      return stop_expression( nxt )
    end
    
    # бэкапим затираемые файлы
    backup_path = File.join( self.state_dir, "file-backup-#{vars['_component_name']}" )
    
    # выполняем спецификацию по отслеживанию ранее записанных файлов
    flag_path = File.join( self.state_dir, "created-file-#{vars['_component_name']}" )
    
    if File.exist?( flag_path )
      previously_written_path = File.read( flag_path ).chomp
      if previously_written_path != path
        # восстановим то что затерли ранее
        restore_or_erase!( previously_written_path, backup_path )
        File.unlink( flag_path )
      end
    end

    if self.cmd == "destroy"
      #if ! is_path_relative( path ) # для локальных удалять не будем
      # неправильная идея неудалять. файл локальный хранится в вышестоящей компоненте! он там может быть лишним.
      # если есть бэкап - восстановим его

      log "file: deleted [#{path}] due to destroy"
      #end
      if File.exist?( flag_path )
        restore_or_erase!( path, backup_path )
        File.unlink( flag_path )
      end
#      unset_component_created_flag( vars["_component_name"] ) if is_component_created_flag(vars["_component_name"])
    else
      # сохраним бекап если еще не сохраняли
      if File.exist?(path)
        if !File.exist?( backup_path )
          # пишем впервые - надо сохранить оригинал
          self.info "making backup of [#{path}] to [#{backup_path}]"
          FileUtils.cp( path, backup_path )
        end
      else
        # файла path не существует
        # надо отметить, что там ничего не было
        File.open( backup_path,"w" ) { |f|
          f.puts EMPTY_BACKUP_MARK
        }
      end
    
      log "Writing file [#{path}]"
      
      File.open( path,"w" ) { |f|
        f.write content
      }
      if vars["mode"]
        mode = vars["mode"]
        if mode =~ /\A0?\d\d\d\z/ # три цифры или 0итрицифры
          mode = mode.to_i(8) # потому что FileUtils.chmod требует числа
        end
        FileUtils.chmod( mode,  path )
      end
      
      
      File.open( flag_path,"w" ) { |flag|
        flag.puts path
      }
      
      # без этого нам destroy не вызовут
#      set_component_created_flag( vars["_component_name"] )
#      create_fake_state( vars, path )
#     оставим это пока на потом. потому что и у [os] такая же история
#     а с ним надо еще аккуратнее смотреть..
#     потому что если у os destroy какой-то весьма деструктивный, а мы его возьмем и удалим
#     или пуще просто переименуем - то он наделает делов
#     такая вот запуск-тонкость. запишем в спеки тулу.
    end

    stop_expression( nxt )
    #perform_expression( nxt )
  end
  
=begin
  def create_fake_state( vars, fpath )
    z = Zapusk.new
    z.name = vars["_component_name"]
    z.parent = self
#    z.params = { "sections" => [ {"type" => "file", "path" => fpath, "hilevel"=>true } ] }
    z.params = {"path" => fpath}
    z.dir = z.state_dir
    z.prepare_state_dir
    File.open( File.join(z.state_dir,"main.ini"),"w") { |f|
      f.puts "####### file"
      f.puts "path={{path}}"
    }
  end
=end  

end

Zapusk.prepend DasPerformFile
