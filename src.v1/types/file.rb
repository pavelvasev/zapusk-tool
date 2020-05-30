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
      if previously_written_path != flag_path
        File.unlink( previously_written_path ) if File.exist?( previously_written_path )
        log "file: deleted [#{previously_written_path}] due to path change"
      end
    end

    if self.cmd == "destroy"
      #if ! is_path_relative( path ) # для локальных удалять не будем
      # неправильная идея неудалять. файл локальный хранится в вышестоящей компоненте! он там может быть лишним.
      File.unlink( path ) if File.exist?( path )
      log "file: deleted [#{path}] due to destroy"
      #end
      File.unlink( flag_path ) if File.exist?( flag_path )
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
    end

    stop_expression( nxt )
    #perform_expression( nxt )
  end

end

Zapusk.prepend DasPerformFile
