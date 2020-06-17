# aim: stack tracing, which we need for diagnosis in case of errors or exceptions

module DasLogging

  def track_stack( zchild )
    @stack ||= []
    @stack.push zchild
    res = yield
    @stack.pop
    res
  end
  
  # коряво конечно - получается мы считаем что стек и parent согласованы.. ну да ладно, пока так.
  def current_stack_top
    return self if @stack.nil?
    return self if @stack.length == 0
    return @stack[-1].current_stack_top
  end

  def stack_str
    @stack
    p = self
    acc = []
    while p do
      acc.push p
      p=p.parent
    end
    str = ""
    c=1
    acc.each do |p|
      #str = str + ("  " * (c-1)) + "^- global_name=[#{p.global_name}] dir=[#{p.dir}] state_dir=[#{p.state_dir}] cmd=[#{p.cmd}]\n"
      str = str + "- global_name=[#{p.global_name}] dir=[#{p.dir}] state_dir=[#{p.state_dir}] cmd=[#{p.cmd}]\n"
      #c=c+1
    end
    str
  end

end

Zapusk.prepend DasLogging
