# экспериментально!
# назначение: выполнить [rb]

module DasPerformRb

  def perform_type_rb( vars, nxt )
    log "perform_type_rb: invoked with cmd=#{cmd}, subcomponent.name=#{vars['name']}"

    code = vars[ self.cmd ] || vars[ "default" ]

    if !code
      log "perform_type_rb: record for cmd #{self.cmd} not found, skipping"
      return :ok_no_cmd_record
    end
    r = eval( code )
    stop_expression( nxt )
    r.is_a?(Symbol) ? r : :ok
  end

end

Zapusk.prepend DasPerformRb
