# aim: compute zapusk program

module DasPerform

  def perform
    ready?

    k = :done
    for c in self.comps do
      k = perform_component( c )
      raise "not a symbol!" if !k.is_a?(Symbol)
      if k == :stop
        # return :stop
        # да, вопрос - это пока у нас получается локальный стоп
        k = :done
        break
      end
    end

    # ну получается мы возвращаем что вернул последний из компонент.. ок..
    k
  end

  def perform_component( c )
    perform_expression( prepare_expression( c["sections"] ) )
  end

  def prepare_expression( array ) # overrided
    array
  end

  # выполняет шаги, записанные в array
  def perform_expression( array )
    if array.length > 0
      computed = compute_subcomponent_vars( array[0] )
      perform_subcomponent( computed, array[1..-1] )
    else
      :skipped_expression_empty
    end
  end

  # выполняет 1 шаг
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
  
  # feature: напечатать warning если еще остались шаги, а мы их делать не будем
  def stop_expression( array )
    if array.length > 0
      warning "following steps never will be performed: [#{array.inspect}]"
    end
    :done
  end

end

Zapusk.prepend DasPerform
