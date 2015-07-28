# -*- coding: utf-8 -*-

require 'zaru_hash'
require 'find'
require 'kconv'

module IkkiLinerUtil

  def is_start_skill_line?(line)
    if line =~ /<TABLE\sWIDTH=530\sCLASS=PD0><TR\sCLASS=B2><TD\sWIDTH=30>Lv<TD\sWIDTH=250>スキル<TD\sWIDTH=100>SP<TD\sWIDTH=120>ギフト<TD\sWIDTH=30>GP<BR><\/TR>/
      return true
    end
  end
  
  def is_start_emb_line?(line)
    if line =~ /<TABLE\sWIDTH=650\sCLASS=PD2><TR><TD\sCLASS=BG1>エンブリオ<\/TD><\/TR><\/TABLE>/
      return true
    else
      return false
    end
  end

  def is_enum_char_table_head?(line, enum)
    if line =~ /<TABLE\sWIDTH=870\sCLASS=BG0><TR><TD\sWIDTH=30><IMG\sSRC=".*?"\sWIDTH=30\sHEIGHT=30><\/TD><TD\sCLASS=Y5i><B\sCLASS=W5i>ENo.#{enum}<\/B>/ and line =~ /各種宣言をする/
      return true
    else
      return false
    end
  end
  
  def is_acion_lines?(line)
    if line =~/<I\sCLASS=F4>(.+?)の連続行動！<\/I>/ or line =~/<I\sCLASS=F4>(.+?)の行動！<\/I>/
      return true
    else
      return false
    end
  end
  
  def ret_actions_agent(line)
    if line =~/<I\sCLASS=F4>(.+?)の連続行動！<\/I>/
      return $1
    elsif line =~/<I\sCLASS=F4>(.+?)の行動！<\/I>/
      return $1
    else
      STDERR.puts "Error"
      exit
    end
  end
  
end
