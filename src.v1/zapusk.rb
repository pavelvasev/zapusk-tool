#!/usr/bin/env ruby
# не смог найти как заставить работать это:
# !/usr/bin/env ruby  "--encoding utf-8:utf-8"
# note `--encoding utf-8:utf-8` -- this effects that external files are considered as utf-8
# and that internally ruby will store strings as utf-8 too
# поэтому вот так:

  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
  
# а без этих вещей, если локаль как-то не так настроена, то руби падает на чтении ини-файлов  

this_script_path = File.expand_path File.dirname(__FILE__)

require_relative "./z1"

begin

z = Zapusk.new
z.debug = ENV["ZAPUSK_DEBUG"]
z.debug = nil if z.debug == ""
z.padding = ENV["ZAPUSK_PADDING"] || ""
# todo this idea.. to start with something useful
#z.log "zapusk: loaded. [#{this_script_path}]"

z.init_from_args( ARGV )
z.load_global_conf
# если стейт-дир указана в каталоге - забиваем на zapusk.conf
# потому что.. читать его оттуда это оксюморон - там он сгенерирвоанный
# а читать его из dir это тупняк - ибо может перебиться state-dir.
# останется гибрид - прочитать таки из каталога dir, но не читать state-dir оттуда.

if !z.state_dir
  z.init_from_zapusk_conf( File.join( z.dir, "zapusk.conf" ) )
end
z.name ||= File.basename( File.expand_path( z.dir ),".zdb" )
z.init_from_dir
z.zdb_lookup_dirs.push(File.join( Zapusk::TOOL_DIR,"lib" ))
z.ready?

z.send( (ENV["ZAPUSK_PADDING"] ? :log : :info), "zapusk: started. #{z.dir} :: #{z.cmd}" )

z.log z
z.log z.dump_components
z.log "ready?=#{z.ready?}"

r = z.perform

#z.info "zapusk: finished. r=#{r}"
z.send( (ENV["ZAPUSK_PADDING"] ? :log : :info), "zapusk: finished. #{z.dir} :: #{z.cmd} result=#{r}" )

rescue => err
  STDERR.puts err.message
  if z && z.debug
    STDERR.puts err.backtrace.join("\n")
  else
    STDERR.puts err.backtrace[0..3].join("\n")
  end
  STDERR.puts "~~~~~~~~~~"
  STDERR.puts z.stack_str
  STDERR.puts "~~~~~~~~~~"  
  exit 5
end