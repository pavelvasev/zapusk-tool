#!/usr/bin/env ruby

require "date"

# проверка на машину
s=ENV["machine"]||""
if s.length > 0
  m=s.split(/[\s,]+/)
  h=`hostname -s`
  if ! m.include?( h )
    exit 100
  end
end

# дальнейшие проверки пойдут только если не указан zapusk --force
if (ENV["ZAPUSK_FORCE"] || "").length > 0
  exit 0
end

# проверка на день недели
# при этом если указан zapusk-force ключ, то проверка не проводится
s=ENV["day"]||""
if s.length > 0
  d = s.split(/[\s,]+/).map(&:to_i)
  today=Date.today.cwday  
  if ! d.include?(today)
    puts "xif: today's day #{today} is not in list of days #{d.inspect}"
    exit 100
  end
end

exit 0
