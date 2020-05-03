class Zapusk
  CODES_DIR=File.expand_path( File.dirname(__FILE__) )
  TOOL_DIR=File.expand_path( File.join( File.dirname(__FILE__), ".." ))
end

Dir[ File.join(Zapusk::CODES_DIR,"z1_*.rb")].sort.each do |f|
#  STDERR.puts "req #{f}"
#  require_relative f
  require f
end