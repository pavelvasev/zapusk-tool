module DasPerformCommands

  def perform_type_commands( vars, nxt )
  
    # these commands should pass specially
    if self.cmd == "destroy" || self.cmd == "remove_removed" || self.cmd == "list-all" #destroy cmd always passes..?
      desired_route = vars[self.cmd]
      if !desired_route
        # anyway call.. it will be denied (if no state) later
        return perform_expression( nxt )
      end
      # ok, there will be exact route for them
    end

    route=vars[self.cmd] || vars["default"]
    log "perform_type_commands: cmd `#{self.cmd}` route is `#{route}`"
    if route
      route = route.is_a?(String) ? route : "apply"
      route_parts = route.split(/[\s,]/)
      res=:pending
      for part in route_parts do
        keepcmd=self.cmd
        self.cmd = part
        res = perform_expression( nxt )
        self.cmd=keepcmd
      end
      return res
    end
    

    return :skipped_no_route
  end

end

Zapusk.prepend DasPerformCommands
