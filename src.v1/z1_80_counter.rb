module DasCounter
  
  attr_accessor :done_cmd_counter
  
  def perform_type_os( vars,nxt )
    r = super
    if r == :done || r == :stop
      self.done_cmd_counter = (self.done_cmd_counter || 0) + 1
    end
    r
  end
  
  def component_zapusk_perform( z )
    r = super
    self.done_cmd_counter = (self.done_cmd_counter || 0) + (z.done_cmd_counter || 0)
    r
  end
  
  def perform
    s = super
    #[s, self.done_cmd_counter]
  end

end

Zapusk.prepend DasCounter
