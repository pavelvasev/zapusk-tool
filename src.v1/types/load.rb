# Предназначение: выполнить zdb-тип из указанной директории

# например:
# [load]
# dir=my-files

module DasPerformLoad

  #attr_accessor :force

  def perform_type_load( vars, nxt )
    dir = vars["dir"] || raise("perform_type_load: dir not specified!")
    if is_path_relative( dir ) # relative to zdb_dir
      dir = File.join( File.expand_path(self.dir), dir )
    end
    log "perform_type_load: using dir [#{dir}]"
    do_perform_zdb( dir, vars, nxt )
  end

end

Zapusk.prepend DasPerformLoad
