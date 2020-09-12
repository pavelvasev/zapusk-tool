# aim: parse command line args

module DasArgs
  
  def init_from_args(args)
    # info "init_from_args: args=#{args.inspect}"
  
    self.cmd = nil
    i=0
    while i < args.length do
      v = args[i]
      if v == "--zdb" || v == "--zdb_dir" 
        # (second variant reason: to be same as --state_dir)
        # одна проблема с --zdb_dir в том, что а вдруг это не каталог, а ресурс? https://github/some/alfa.zdb ???
        # ну и что - пофиг. если будет ресурс все-равно его дорабатывает, типа добавлять files.txt
        self.dir = args[i+1] || (raise "init_from_args: where is --zdb_dir parameter value?")
        log "init_from_args: zdb_dir assigned: #{self.dir}"
        if !File.directory?(self.dir)
          
          raise "init_from_args: not a directory zdb_dir=#{dir}"
        end
        i=i+2
        next
      end
      if v == "--state_dir"
        self.state_dir = args[i+1] || (raise "init_from_args: where is state_dir parameter value?")
        log "init_from_args: state_dir assigned: #{self.state_dir}"
        if !File.directory?(self.state_dir)
          log "init_from_args: not a directory state_dir=#{self.state_dir}. ok."
          # init should not create state dir - it must be created later, when it required
          # for example on destroy action, state dir should not be created
          # FileUtils.makedirs( self.state_dir )
          # raise "init_from_args: not a directory state_dir=#{self.state_dir}"
        end
        i=i+2
        next
      end
      if v == "--only"
        self.only = args[i+1] || (raise "init_from_args: where is only parameter value?")
        log "init_from_args: only assigned: #{self.only}"
        i=i+2
        next
      end

      if v == "--padding"
        self.padding = args[i+1] || (raise "init_from_args: where is padding parameter value?")
        i=i+2
        next
      end
      if v == "--debug"
        self.debug = true
        log "init_from_args: debug true."
        i=i+1
        next
      end
      if v == "--force"
        # self.force = true
        # решено пока использовать переменную..
        log "init_from_args: force true."
        ENV["ZAPUSK_FORCE"] = "--force"
        i=i+1
        next
      end
      if v == "--deferred-master"
        # self.force = true
        # решено пока использовать переменную..
        log "init_from_args: deferred master true."
        ENV["ZAPUSK_DEFERRED_PATH"] = "" # будет использовано в слое B-deferred
        i=i+1
        next
      end      
      if v == "--a"
        param = args[i+1] || (raise "init_from_args: where is the parameter value?")
        arr = param.split("=").map{|s|s.chomp}
        self.external_params ||= {}
        self.external_params[ arr[0] ] = arr[1]
        log "init_from_args: assigned param --a '#{arr[0]}=#{arr[1]}'"
        i=i+2
        next
      end
      
      if self.cmd.nil?
        self.cmd=args[i]
        i=i+1
        next
      end
      
      raise "init_from_args: unparsed argument! v=#{v}. btw args=#{args.inspect}"
      
      i=i+1
    end
    
    self.cmd ||= begin
      log "init_from_args: cmd not specified, assuming default value for cmd is 'apply'"
      "apply"
      end
  
    
    
  end

end

Zapusk.prepend DasArgs