# Предназначение: делать указанные команды только один раз
# (а не указанные - как обычно)
# например:
# [once]
# system-update

module DasPerformOnce

  #attr_accessor :force

  def perform_type_once( vars, nxt )
    # есть некий вопрос.. что у нас в vars? возможно, много лишнего, и не из области знаний про команды
    # а и всякое постороннее типа state_dir..
    log "ONCE filter. vars=#{vars.inspect}"
    flags_dir_var_name="dir"
    if self.cmd == "destroy"
      flags_dir = vars[ flags_dir_var_name ] || self.state_dir
      fn = File.join( flags_dir,"once-#{vars['_component_name']}-*.flag" )
      log "ONCE filter: destroy => delete all my flags"
      Dir.glob( fn ).each do |filepath|
        log fn
        File.unlink( filepath )
      end
    elsif vars[ self.cmd ]
      if (ENV["ZAPUSK_FORCE"] || "").length > 0
        log "ONCE filter: force flag detected, passing anyway."
        return perform_expression( nxt )
      end
      # трюк - надо это делать с учетом имени компоненты
      flags_dir = vars[ flags_dir_var_name ] || self.state_dir
      FileUtils.makedirs( flags_dir )

      fn = File.join( flags_dir,"once-#{vars['_component_name']}-#{self.cmd}.flag" )
      if File.exist?( fn )
        info "ONCE filter: cmd=#{self.cmd} skipped due to `once` setting in #{self.global_name}/#{vars['_component_name']}"
        return :skipped_due_to_once
      end
      r = perform_expression( nxt )
      # если не свалились - значит команда выполнена успешно

      File.open( fn,"w") { |f| f.puts Time.now }
      return r
    end
    perform_expression( nxt )
  end

end

Zapusk.prepend DasPerformOnce
