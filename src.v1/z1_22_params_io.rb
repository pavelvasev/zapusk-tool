# aim: 
# * read and write zapusk language
# * read and write params language (e.g. attrname=value)

# Zapusk language has following structure in memory:
# * This is hash, P
# * Each `##### name #### ` section is stored as P["sections"][i] = { "name" => name, "hilevel" => true }
# * Each `[name]` section is stored as P["sections"][i] = { "name" => name, "hilevel" => false }
# * Parameters before any sections stored as P["paramname"]=value
# * Parameters inside any sections stored in their hash (noted above).

# Thus zapusk language structure is a linear array of ### and [] sections
# (they nesting is interpreted later using `hilevel` flag)

require "shellwords"

module DasParamsIO

  def assign_param_value( acc, name, value )
    sections = acc["sections"]
    if sections
      sections.last[name] = value
    else
      acc[ name ] = value
    end
    acc
  end

  def add_section( acc, name, hilevel )
      acc["sections"] ||= []
      if hilevel && acc["sections"].detect{ |s| s["name"] == name }
        raise "add_section: section with name `#{name}` already defined!"
        # todo разобраться бы с этим
      end
      s = { "name" => name}
      s["hilevel"] = true if hilevel
      
      acc["sections"].push( s  )
      acc
  end

  def read_params_file( filepath,acc={} )
    content = File.readlines( filepath )
    read_params_content( content, {}, lambda {|i| filepath } )
    # todo: react on "include"
  end
  
  # тема file-resolver-lambda
  # типа передаем функцию, которая по номеру строки сообщит нам имя файла
  # если это понадобится для каких-то целей

  def read_params_content( content,acc={},file_resolver_lambda=nil )
    i = 0
    while i <content.length do
      line = content[i].strip
      i = i+1

      if line =~ /^([\w\-_\@]+)\s*=\s*['"](.+)['"]$/ # case: value in quotes
        acc = assign_param_value( acc, $1, $2 )
      elsif line =~ /^([\w\-_\@]+)\s*=\s*"\s*$/ # case: multiline value, e.g. = "
        nama = $1
        stracc = ""
        start_i = i
        found = false
        while i < content.length do
          sl = content[i]
          i = i+1
          if sl.strip == '"'
            found = true
            break
          end
          stracc = stracc + (stracc.length > 0 ? "\n" : "") + sl.chomp
        end
        
        if !found
          fn = file_resolver_lambda ? file_resolver_lambda.call( start_i ) : nil
          warning "un-closed multiline value found: name=#{nama}, file=#{fn}"
          # todo: check for cross-borders of ini parts? e.g. if var is not closed in current part..
        end
        
        # info "long value found: #{stracc}"
        acc = assign_param_value( acc, nama, stracc )
      elsif line =~ /^([\w\-_]+)\s*=\s*(.*)$/ # case: value not in quotes
        acc = assign_param_value( acc, $1, $2 )
      elsif line =~ /^([\w\-_\s]+)\s*$/  # case: boolean value (no = sign => true)
        acc = assign_param_value( acc, $1, true )
      elsif line =~ /^\s*\[(.*)\]/              # case: [section]
        acc = add_section( acc, $1.strip,false )
      elsif line =~ /^\s*###+\s*([\w\-_]+)\s*/  # case: #### header
        acc = add_section( acc, $1.strip,true )
      else
        if line =~ /^\s*(#|``|\/\/)/ || line.length == 0 # if looks like comment or empty - skip it
          next
        end
        fn = file_resolver_lambda ? file_resolver_lambda.call( i ) : nil
        infa = fn ? " from file #{fn}" : ""
        raise "read_comp: failed to parse line: #{line}#{infa}"
      end
    end
    return acc
  end


#####################################################################################
  
  def write_params_block( f, v, do_escape, name_prefix )
    #log "write_params_block: called for #{f.path} with v=#{v.inspect}"
    for k in v.keys do
      if v[k].is_a?(Hash)
        # raise "hmm? think over! v[k]=#{v[k].inspect}"
        #fn = f.path + "_#{k}"+File.extname(f.path)
        #write_params_file( fn, v[k], do_escape )
        #f.puts "#{name_prefix}#{k}_file=#{fn}"
        #write_params_block( f, v[k], do_escape, "#{k}_" )
      elsif v[k].is_a?(Array)
        if !do_escape # do_escape это у нас признак sh-файла.. - решено не сохранять в него секции
        for a in v[k] do
          if a.is_a?(Hash)
            f.puts "[#{a['name']}]"
            write_params_block( f,a,do_escape,name_prefix )
          end
        end
        end
      else
        next if k == "_component_name" # не будем сохранять
        str = v[k].to_s
  #        puts "k=#{k}, str=#{str}"
  #        str.gsub!(/[^\\](")/,'\"') # quote quotes
  #        str = "\"#{str}\"" if str =~ /\s/ # add quotes if has spaces
        str = if do_escape
          k = k.gsub(/[^\w]/,"_") # для баша стараемся
          Shellwords.escape(str) # for bash, it will escape ok
        else
          if str =~ /\n/ # our multiline packing
            "\"\n#{str}\n\""
          else
            str
          end
        end
        
        f.puts "#{name_prefix}#{k}=#{str}"
      end # if
    end #for
  end
  
  def write_params_file( filepath,v,do_escape )
    if self.use_state_params
      log "skipped write to #{filepath} due to use_state_params flag"
      return
    end
    File.open( filepath,"w") do |f|
      write_params_block( f, v, do_escape, "" )
    end
  end

end

Zapusk.prepend DasParamsIO