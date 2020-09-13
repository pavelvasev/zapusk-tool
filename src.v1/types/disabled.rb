# экспериментально!
# назначение: ничего не делать

module DasPerformDisabled

  def perform_type_disabled( vars, nxt )
    log "perform_type_disabled: invoked with cmd=#{cmd}, subcomponent.name=#{vars['name']}"
    :ok
  end

end

Zapusk.prepend DasPerformDisabled
