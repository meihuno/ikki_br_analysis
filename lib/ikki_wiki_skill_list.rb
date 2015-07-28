# coding: utf-8
require 'hpricot'
require 'find'
require 'open-uri'
require 'zaru_hash'

class IkkiWikiSkillList

  def ret_table_from_remote
    turl = "http://www55.atwiki.jp/ikkifantasy/pages/57.html"
    doc = Hpricot( open(turl).read )
    table = (doc/"table tr")
    return table
  end
  
  def initialize(dir=".")
    @dir = dir
  end
  
  def check_level(str)
    if str == "5"
      return true
    elsif str == "10"
      return true
    elsif str == "15"
    return true
    elsif str == "20"
      return true
    elsif str == "25"
      return true
    else
      return false
    end
  end

  def ret_table_from_local
    target_array = Array.new
    Find.find(@dir) {|path|
      if path =~ /57\.html/
        target_array << path
      end
    }
    
    file = target_array.first
    f = open(file, "r")
    doc = Hpricot(f)

    table = (doc/"table tr")
    return table
  end
  
  def ret_skill_name_hash_from_local
    table = ret_table_from_local

    skill_effect_hash = Hash.new
    skill_sp_hash = Hash.new
    
    table.each {|tag|
      str = tag.inner_text
      array = str.split(/\n\t\t/)
      if check_level(array[1])
        skill_name = array[2]
        sp_cost = array[3]
        effect = array[6]
        skill_effect_hash.push_array(skill_name, effect)
        skill_sp_hash.push_array(skill_name, sp_cost)
      end
    }
    r_hash = Hash.new
    r_hash[:effect] = skill_effect_hash
    r_hash[:sp] = skill_sp_hash
    return r_hash
  end
  
end
