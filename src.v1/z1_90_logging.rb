# aim: loggin facilities

module DasLogging

  attr_accessor :padding
  attr_accessor :debug

  def initialize
    self.padding = ""
    super
  end

  attr_accessor :lst_log_item
  def log( msg )
    self.lst_log_item=msg
    puts "#{padding}#{msg}" if debug
  end

  def info( msg )
    puts "\e[96m#{padding}*** #{msg}\e[0m"
#    cw = padding.length + 3 + msg.length
#    aw = 120 - cw
#    extra = ("*" * (aw > 0 ? aw : 0))
#    suffix = extra.length > 0 ? " " : ""
#    puts "#{padding}*** #{msg}#{suffix}#{extra}"
  end
  
  def warning( msg )
    puts "#{padding}*** WARNING: #{msg}"
  end  

  def perform
    log "perform:[#{self.dir}] started. cmd=#{self.cmd}"
    r=super
    log "perform:[#{self.dir}] finished. r=#{r}"
    r
  end

  def perform_component( c )
    #info "perform_component c=#{c.inspect}"
    log "perform_component: name=#{c['name']}"
#    log "c=#{c.inspect}"
    r = super
    log r
    r
  end
  
  def do_perform_zdb( path, vars,nxt )
    log "#{padding}do_perform_zdb: type path=#{path}"
    super
  end
  
#  def write_params_file( fn,v )
#    log "write_params_file: #{fn} "
#    super
#  end
  
  def read_params_file( fn,acc={} )
#    log "read_params_file: #{fn} "
    res = super
#    log "read result: #{res.inspect}"
    res
  end

  def parent=(p)
    self.padding = p.padding + "  "
    super
  end

end

Zapusk.prepend DasLogging
