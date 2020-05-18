# Предназначение: на уровне машины отслеживать установку компоненты
# и не давать ее удалять, если у нее есть другие пользователи (те кто заказал установку такой-же компоненты
# с такими же ключевыми параметрами)

# например:
# [guard]
# key=created-users/{{user}}

# [guard]
# key=host-ftp

# Алгоритм
# создает где-то папку /zapusk/_guards/key и в ней файл global_name
# и получается что наличие файлов в папке _guards/key/ означает для нас
# что произведена установка.

require "fileutils"

module DasPerformGuard

  def perform_type_guard( vars, nxt )

    guards_dir = vars[ "dir" ] || "/zapusk/_guards/"
    # info "guards_dir=#{guards_dir}"
    key_dir = File.join( guards_dir,vars['key'] )
    FileUtils.makedirs( key_dir, :mode => (guards_dir == "/zapusk/_guards/" ? 0777 : nil) )
    # if global guard created, it should have free access flag..
    # or maybe save it in local user home?
    # todo..
    
    this_global_name = self.global_name + "-" + vars["_component_name"]
    fn = File.join( key_dir,"#{this_global_name}.flag" )

    if self.cmd == "destroy" || self.cmd == "remove_removed"
      if File.exist?( fn )
        log "GUARD: destroying own flag file: #{fn}"
        File.unlink( fn ) 
      end
      fmask = File.join( key_dir,"*.flag" )
      log "GUARD: checking if other users exist"
      Dir.glob( fmask ).each do |filepath|
        info "GUARD: other user found. skipping destroy due to: #{filepath}"
        return :done_destroy_skipped_due_other_users
      end
      log "GUARD: no other users, passing action for ongoing processing: #{self.cmd}"
      FileUtils.remove_dir( key_dir )
      return perform_expression( nxt )
    end
    
    if !File.exist?( fn )
      File.open( fn,"w") { |f|
        f.puts self.dir
      }
    end
    
    perform_expression( nxt )
  end

end

Zapusk.prepend DasPerformGuard
