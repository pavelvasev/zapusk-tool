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

    if is_path_relative( path ) # relative
      path = File.join( self.state_dir, path )
    end

    if self.cmd == "destroy"
      if ! is_path_relative( path ) # для локальных удалять не будем
        File.unlink( path ) if File.exist?( path )
      end
    else
      File.open( path,"w" ) { |f|
        f.write content
      }
      if vars["mode"]
        FileUtils.chmod( vars["mode"],  path )
      end
    end

    perform_expression( nxt )
  end

end

Zapusk.prepend DasPerformFile
