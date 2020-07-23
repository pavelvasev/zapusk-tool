################################################################
# aim: patch zapusk for necessary things for `testing` feature

module DasTestingFeature

  # идея: если видим 
  # [command]
  # some
  # а команда у нас some-testing
  # то пройти эту some,
  # но команду изменить на testing
  
  # по сути, это вынос стандартного поведения на системный уровень
  def perform_type_commands( vars, nxt )
    # these commands should pass specially
    if self.cmd =~ /^(.+)-testing$/
      desired_route = vars[$1]
      if desired_route
        # anyway call.. it will be denied (if no state) later
        a = self.cmd
        self.cmd = "testing"
        r = perform_expression( nxt )
        self.cmd = a
        return r
      end
    end
    super
  end

=begin
  def perform
    # mark env so scripts may examine this
    if self.cmd == "testing"
      ENV["ZAPUSK_TESTING"]="-testing"
    end
    super
  end
=end  

end

Zapusk.prepend DasTestingFeature
