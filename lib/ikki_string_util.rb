# -*- coding: utf-8 -*-

require 'zaru_hash'
require 'find'
require 'kconv'

module IkkiStringUtil
  def ret_conf(line)
    line = line.toutf8
    line3 = line.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
    line4 = line3.chars.collect { |c| (c.valid_encoding?) ? c : "\uFFFD" }.join
    return line4
  end

  def get_line(io)
    begin
      line2 = io.gets
      line2.chomp!
      line2 = ret_conf(line2)
      return line2
    rescue
      return false
    end
  end
  
end
