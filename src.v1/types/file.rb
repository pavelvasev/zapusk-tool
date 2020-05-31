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

  def perform_type_file( vars, nxt )
    path = vars["path"] || raise("perform_type_file: path not specified")
    content = vars["content"] || ""
    # todo: может list на вход - список файлов?
    # info "performing file, #{vars.inspect}"
    
    if is_path_relative( path ) # relative
      path = File.join( self.state_dir, path )
    end
    
    # выполняем спецификацию по отслеживанию ранее записанных файлов
    flag_path = File.join( self.state_dir, "created-file-#{vars['_component_name']}" )
    if File.exist?( flag_path ) 
      previously_written_path = File.read( flag_path ).chomp
      if previously_written_path != path
        File.unlink( previously_written_path ) if File.exist?( previously_written_path )
        log "file: deleted old [#{previously_written_path}] due to path change"
      end
    end

    if self.cmd == "destroy"
      #if ! is_path_relative( path ) # для локальных удалять не будем
      # неправильная идея неудалять. файл локальный хранится в вышестоящей компоненте! он там может быть лишним.
      File.unlink( path ) if File.exist?( path )
      log "file: deleted [#{path}] due to destroy"
      #end
      File.unlink( flag_path ) if File.exist?( flag_path )
#      unset_component_created_flag( vars["_component_name"] ) if is_component_created_flag(vars["_component_name"])
    else
      File.open( path,"w" ) { |f|
        f.write content
      }
      if vars["mode"]
        FileUtils.chmod( vars["mode"],  path )
      end
      log "file: wrote [#{path}]"
      
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
