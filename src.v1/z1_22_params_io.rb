# aim: 
# * read and write zapusk language
# * read and write params language (e.g. attrname=value)

# Zapusk language hash following structure in memory:
# * This is hash, P
# * Each `##### name #### ` section is stored as P[name] => hash_for_attrs
#    + hash_for_attrs["hilevel"]=true
# * Each `[name]` section is stored same, as P[name] => hash
# * Names of all above sections are collected in special key P["sections"]

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
    read_params_content( content )
    # todo: react on "include"
  end

  def read_params_content( content,acc={} )
    i = 0
    while i <content.length do
      line = content[i].strip
      i = i+1

      if line =~ /^([\w\-_\@]+)\s*=\s*['"](.+)['"]$/ # case: value in quotes
        acc = assign_param_value( acc, $1, $2 )
      elsif line =~ /^([\w\-_\@]+)\s*=\s*"\s*$/ # case: multiline value, e.g. = "
        nama = $1
        stracc = ""
        while i < content.length do
          sl = content[i]
          i = i+1
          break if sl.strip == '"'
          stracc = stracc + (stracc.length > 0 ? "\n" : "") + sl.chomp
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
        raise "read_comp: failed to parse line: #{line}"
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