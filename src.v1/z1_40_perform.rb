# aim: compute zapusk program

module DasPerform

  def perform
    ready?

    for c in self.comps do
      k = perform_component( c )
      raise "not a symbol!" if !k.is_a?(Symbol)
      if k == :stop
        # return :stop
        # да, вопрос - это пока у нас получается локальный стоп
        break
      end
    end

    :done
  end

  def perform_component( c )
    perform_expression( prepare_expression( c["sections"] ) )
  end

  def prepare_expression( array ) # overrided
    array
  end

  def perform_expression( array )
    computed = compute_subcomponent_vars( array[0] )
    perform_subcomponent( computed, array[1..-1] )
  end

  def perform_subcomponent( c, nxt )
    type = c["type"]
    mname = "perform_type_#{type}"
    # STDERR.puts ">>>> mname=#{mname}"
    if self.respond_to?(mname)
      self.send( mname, c, nxt )
    else
      self.send( "perform_type_zdb", c, nxt )
    end
  end

end

Zapusk.prepend DasPerform
