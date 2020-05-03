# Предназначение: делать поясняющий вывод для человека
# например:
# [info]
# system-update=Установка системного ПО чруты

module DasPerformInfo

  def perform_type_info( vars, nxt )
    hint = vars[ self.cmd ] || vars[ "default" ]
    if hint
      info( hint )
    end
    if nxt.length > 0
      perform_expression( nxt )
    else
      :done
    end
  end

end

Zapusk.prepend DasPerformInfo
