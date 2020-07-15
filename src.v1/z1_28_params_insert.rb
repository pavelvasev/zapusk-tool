# WARNING! EXPERIMENTAL!
# aim: if see "params" param in some params list,
#      insert current zdb component params there

module DasParamsComputeInsert

  def compute_params( params, extra_know, error_msg_context,testmask=nil )
    if params["params"]
      log "ok i see params in params. btw params=#{params}"
      params_of_current_zdb = self.params
      other_trash = {"hilevel"=>true, "_component_name"=>"papapdf", "type"=>"papapdf", "parent_global_name"=>"vasev", 
                     "component_global_name"=>"vasev-papapdf", "stack_of_types_dirs"=>"/zapusk/vasev.zdb",
                     "type_dir" => "xxx"}
      trash_names = global_conf.merge( zapusk_params ).merge( other_trash )
      a = params_of_current_zdb.reject{ |k,v| trash_names.has_key?(k) }
      log "%params% keyword magic: inserting this things: #{a.inspect}"
      params = a.merge( params )
      params.delete( "params" )
      # now params-arg fulfilled with this zdb params
      # and if params-arg has some key, they override zdb params
    end
    super( params, extra_know, error_msg_context, testmask )
  end

end

Zapusk.prepend DasParamsComputeInsert