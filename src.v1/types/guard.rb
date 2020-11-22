# Предназначение: на уровне машины отслеживать установку компоненты
# 1 не давать ее удалять, если у нее есть другие пользователи (те кто заказал установку такой-же компоненты
# с такими же ключевыми параметрами)
# 2 передавать управление главной компоненте

# например:
# [guard]
# key=created-users/{{user}}

# [guard]
# key=host-ftp

# Алгоритм
# создает где-то папку /zapusk/_guards/key и в ней файл global_name
# и получается что наличие файлов в папке _guards/key/ означает для нас
# что произведена установка.

# Передача управления
# Если на машине установлено несколько системных компонент, защищаемых одним guard, то у них могут быть
# разные наборы параметров. Например в host-certbot это выяснилось - на Лакте необходимо указывать другой каталог.
# Но компонентой должен управлять какой-то один набор параметров, чтобы они не боролись.
# Поэтому сделано так, что если guard-раздел видит флаг другой компоненты но с высшим приоритетом,
# то он передает управление ей. Это не очень изящное решение, т.к. оно требует чтобы разные guard-разделы
# с одним ключем key считались одинаковыми. Но по факту это сейчас так.

# todo
# при смене приоритета будет и старый файл, и новый



require "fileutils"

module DasPerformGuard

  def perform_type_guard( vars, nxt )
#    info "guard vars = #{vars.inspect}"
#    info "guard ext params = #{self.external_params}"
#    info "cmd = #{self.cmd}"
#    info "self.state_dir=#{self.state_dir}"

    guards_dir = vars[ "dir" ] || "/zapusk/_guards/"
    # info "guards_dir=#{guards_dir}"
    key_dir = File.join( guards_dir,vars['key'] )
    priority_prefix = vars['priority'] ? "#{vars['priority']}-" : ""
    FileUtils.makedirs( key_dir, :mode => (guards_dir == "/zapusk/_guards/" ? 0777 : nil) )
    # if global guard created, it should have free access flag..
    # or maybe save it in local user home?
    # todo..
    
    this_global_name = self.global_name + "-" + vars["_component_name"]
    fn = File.join( key_dir,"#{priority_prefix}#{this_global_name}.state" )
    fmask = File.join( key_dir,"*.state" )

    if self.cmd == "destroy" || self.cmd == "remove_removed"
      if File.exist?( fn )
        log "GUARD: destroying own flag file: #{fn}"
        File.unlink( fn )
      end
      
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
        f.puts self.state_dir
      }
    end
    
    host = Dir.glob( fmask ).sort.first
    
    host_state_dir = File.readlines( host ).first.chomp

    if File.expand_path(host_state_dir) == File.expand_path(self.state_dir)
      return perform_expression( nxt )
    end
    if ! File.directory?( host_state_dir )
      warning "guard: host directory does not exist! dir=#{host_state_dir}. my state is #{self.state_dir}"
      return perform_expression( nxt )
    end
    
    # so, moving to host dir
    z = Zapusk.new
    #z.dir = host_state_dir
        
    zconf = File.join( host_state_dir, "zapusk.conf" )
    z.init_from_zapusk_conf( zconf ) # by the way this will set 'use_state_params' flag.

    z.parent = self
    track_stack(z) do
      # we need to get params from state
      # because vars from these params may be used in computations
      # in own params of component..
      state_params_file = File.join( host_state_dir, "params.txt" )
      host_params = read_params_file( state_params_file )
      z.external_params = self.external_params.merge( host_params )
      # типа хост-параметры важнее.. но и наши надо учесть

      z.init_from_dir
      z.cmd = self.cmd
      z.perform
    end # track stack

  end

end

Zapusk.prepend DasPerformGuard
