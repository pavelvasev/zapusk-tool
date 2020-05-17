# aim: load **special steps**

Dir[ File.join(Zapusk::CODES_DIR,"types","*.rb")].sort.each do |f|
  require f
end