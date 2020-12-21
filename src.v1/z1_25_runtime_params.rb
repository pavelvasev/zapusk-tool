# aim: 

# * load zapusk program from *.ini files
# * load zapusk.conf
# * provide **own_params** -- final params of current program
#   made by extracting `params`` section from loaded program, and mergit it with zapusk conf, external params, and global zapusk conf
# * provide **own_body** -- loaded program of zapusk language (it's structure is desrcibed in params_io.rb)
# * generate **zapusk_params** -- a params to save to zapusk.conf for component state directory

require "pp"

module DasOwnParams

  def init_from_dir
    #log "init_from_dir"
    self.own_params, self.own_body = load_own_params
    import_state_from_params( self.own_params )
    import_state_from_params( self.external_params || {} )
    compute_final_self_params
    import_state_from_params( self.params )
    super
  end

  attr_accessor :external_params # external (computed) params, specified for this component
  attr_accessor :own_params # own NON-computed params (just loaded)
  attr_accessor :params # real runtime param values, computed
  
  attr_accessor :own_body # поле без колонки параметров - суть массив узлов верхних уровней
  
  attr_accessor :own_params_dir_override # override dir where to load params from

  def load_own_params
    srcdir = own_params_dir_override || self.dir

    acc = []
    mask = File.join( srcdir,"*.ini")
    log "load_own_params: loading mask #{mask}"
    gg = Dir.glob( mask  )
    # feature: report more warnings
    if gg.length == 0
      warning "load_own_params: no #{mask} files found!" # Are you sure you are running a zapusk program?"
    end
    
    line_counts = []
    gg.sort.each do |f|
      # log "load_own_params: found #{f}"
      c = File.readlines( f ) # IO. ?
      line_counts.push( [f, c.length] )
      
      # feature: warn if no ####, suggested by Mikhail Bakhterev (among his other suggestions)
      has_header=false
      for k in c do
        if k =~ /^\s*####/
          has_header = true
          break
        end
      end
      if !has_header
        warning "File [#{f}] has no #### blocks!"
      end
      
      acc = acc + c
    end
    
    # функция i => имя файла
    file_name_helper = lambda { |i|
      for file_lc in line_counts do
        return "#{file_lc[0]}:#{i}" if i <= file_lc[1]
        i = i - file_lc[1]
      end
      return "unknown file"
    }

    body = read_params_content( acc, {}, file_name_helper )

    if !body["sections"].is_a?(Array)
      log "load_own_params: loaded content from mask #{mask} have no ini sections!"
      info "loaded content: #{body}"
      return {},[]
      # todo может это и не ошибка
    end
#    log "load_own_params: body=#{body['sections'].inspect}"
    acc2 = []
    acc_own_params = {}
    body["sections"].each do |s|
      if s["hilevel"] && s["name"] == "params"
        s.delete("name") # name should go from zapusk state, here name is just "params"
        s.delete("hilevel")
        acc_own_params = s
      else
        acc2.push( s )
      end
    end
    
#    log "load_own_params: own_params=#{acc_own_params.inspect}, own_body=#{acc2.inspect}"
    return acc_own_params, acc2
    
  end

  def compute_final_self_params
    # порядок вычисления см https://github.com/pavelvasev/zapusk/blob/master/spec-1-parts/30-syntax.md
    p = global_conf || {}
    p = p.merge( zapusk_params )
    p = p.merge( own_params || {} )
    p = p.merge( external_params || {} )

    # вот вторая скобочка означает, что хрен вам, а не параметры извне
    # при вычислении собственных значений..
    p = compute_params( p,{},"#{self.global_prefix}/#{self.name} params" )

#    log "compute_final_self_params: params=#{p.inspect}"
#    log "compute_final_self_params: own_params=#{own_params.inspect}"
    self.params = p
    p
  end
  
  def zapusk_params
    h = {
      "name" => self.name,
      "global_name" => self.global_name,
      "global_prefix" => self.global_prefix,
      "zdb_dir" => File.expand_path( self.dir ),
      "zapusk_tool_dir" => Zapusk::TOOL_DIR,
      "zapusk_tool" => File.join( Zapusk::TOOL_DIR,"zapusk" )
    }
    #log "qq, self.state_dir=#{self.state_dir}"
    h["state_dir"] = File.expand_path( self.state_dir ) if self.state_dir
    #log "qq2"
    if self.external_params
      h["zdb_type"] = self.external_params["type"] ## || self.name
    end
    h
  end

end

Zapusk.prepend DasOwnParams
