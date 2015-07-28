# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'zaru_hash'
require 'ikki_file_util'
require 'ikki_string_util'
require 'ikki_liner_util'
require 'ikki_wiki_skill_list'

class IkkiFantasyAnalysis

  include IkkiLinerUtil
  include IkkiFileUtil
  include IkkiStringUtil

  attr_accessor :pool_dir, :base_dir
  attr_reader :team_name_hash
  attr_reader :team_member_names_hash
  attr_reader :used_skill_hash
  attr_reader :team_name_to_battle_file_hash
  
  def initialize(dir)
    @pool_dir = ret_newest_br_dir(dir)
    @base_dir = ret_newest_base_dir(dir)
    @team_name_hash = Hash.new
    @index_files = Array.new
    @index_teams_hash = Hash.new
    @index_match_file_hash = Hash.new
    @team_member_names_hash = Hash.new
    @used_skill_hash = Hash.new
    @team_name_to_rivals_hash = Hash.new
    @team_name_to_battle_file_hash = Hash.new
    @sk = IkkiWikiSkillList.new("./")
    @char_skgif_hash = Hash.new
    @char_enum_name_hash = Hash.new
    
    @gl_catch_skill_hash = Hash.new
    @gl_name_hash = Hash.new
    @gl_team_hash = Hash.new
    
  end

  def set_char_skgif_index_hash
    @sg_enum_hash = Hash.new
    @char_skgif_hash.each {|enum, sg_hash|
      sg_hash.each {|type, sub_hash|
        sub_hash.each {|sgname,freq|
          if type == :gift
            @sg_enum_hash.push_array(sgname,enum)
            @sg_enum_hash.push_array("#{sgname}:#{freq}",enum)
          else
            @sg_enum_hash.push_array(sgname,enum)
          end
        }
      }
    }
    # p @sg_enum_hash.keys
  end

  def serach_skgif(array)
    if @sg_enum_hash
      c = Array.new
      count = 0
      array.uniq!
      array.each {|str|
        if @sg_enum_hash.has_key?(str)
          if count == 0
            c << @sg_enum_hash[str]
            c.flatten!
          else
            d = @sg_enum_hash[str]
            c = c & d
          end
          count += 1
        end
      }
      c.sort! {|a,b|
        a.to_i <=> b.to_i
      }
      return c
    end
  end
  
  def set_char_enum_name_hash
    kdir = ret_newest_k_dir(bdir="../data")
    k_array = ret_k_files(kdir)
    @char_enum_name_hash = Hash.new
    k_array.each {|file|
      if file =~ /k(\d+)\.html/
        enum = $1
        STDERR.puts "Extract #{enum} and its name data from #{file}"
        r_hash = ret_character_enum_name_hash(file,enum)
        unless r_hash.empty?
          @char_enum_name_hash[enum] = r_hash
        end
      end
    }
  end
  
  def ret_character_enum_name_hash(file, enum)
    r_hash = Hash.new
    io = open(file)
    while line = get_line(io)
      if is_enum_char_table_head?(line,enum)
        lines = line.split(/\r/)
        lines.each_with_index {|ll,idx|
          if ll =~ />愛称</
            
            doc = Hpricot(ll)
            td = (doc/"tr td")
            tmps = Array.new
            td.each {|elem|
              tmps << elem.inner_text
            }
            if tmps.size == 4
              str = tmps[2]
              name = tmps[3]
              if str == "愛称"
                name.gsub!(/<.*?>/,"")
                r_hash[:hypocorism] = name
                return r_hash
              end
            end
          end
        }
      end
    end
    io.close
    return r_hash
  end
  
  def set_char_skgif_hash
    kdir = ret_newest_k_dir(bdir="../data")
    k_array = ret_k_files(kdir)

    k_array.each {|file|
      if file =~ /k(\d+)\.html/
        enum = $1
        STDERR.puts "Extract #{enum} data from #{file}"
        r_hash = ret_character_skill_gift_hash(file)
        @char_skgif_hash[enum] = r_hash
      end
    }
  end
  
  def ret_character_skill_gift_hash(file)
    
    ch_skill_hash = Hash.new
    ch_gift_hash = Hash.new 
    
    io = open(file)
    while line = get_line(io)
      if is_start_emb_line?(line)
        lines = line.split(/\r/)
        lines.each_with_index {|ll,idx|
          if is_start_skill_line?(ll)
            str = lines[idx+1]
            doc = Hpricot(str)
            td = (doc/"tr td")
            tmps = Array.new
            td.each {|elem|
              tmps << elem.inner_text
            }
            
            tmps.each_slice(5) {|a,b,c,d,e|
              level = a
              skill = b
              sp_cost = c
              gift = d
              gift_cost = e
              ch_skill_hash.inc_num(skill,1)
              unless gift == "-"
                ch_gift_hash.inc_num(gift,1)
              end
            }
          end
        }
      end
    end
    io.close
    r_hash = Hash.new
    r_hash[:skill] = ch_skill_hash
    r_hash[:gift] = ch_gift_hash
    return r_hash
  end
  
  def set_team_name_hash
    # チーム名の取得
    @index_files = ret_index_files(@pool_dir)
    first_index_file = @index_files.first
    @team_name_hash = ret_team_hash(first_index_file)
  end
  
  def ret_br_team_name(enom, team_hash)
    rstr = nil
    team_hash.each {|team_name, array|
      if array.index(enom) != nil
        return team_name
      end
    }
    return rstr
  end

  def ret_our_team_name(enum)
    # 自分のチーム名の取得
    our_team = ret_br_team_name(enum, @team_name_hash)
    return our_team
  end
  
  def set_rival_name_hash
    @index_teams_hash.each {|file, teams_hash|
      if @index_match_file_hash.has_key?(file)
        battle_file_hash = @index_match_file_hash[file]
        teams_hash.each {|match_num, team_hash|
          if battle_file_hash.has_key?(match_num)
            filename = battle_file_hash[match_num]
          else
            filename = "not created"
          end
          team_hash.each {|team_name, members|
            STDERR.puts "#{team_name} in #{filename}"
            team_hash.keys.each {|team_name1|
              unless team_name == team_name1
                @team_name_to_rivals_hash.push_array(team_name, team_name1)
                unless filename == "not created"
                  @team_name_to_battle_file_hash.push_array(team_name, filename)
                end
              end
            }
          }
        }
      end
    }
  end

  def ret_eff_array(eff_str)
    eff_array = eff_str.split(/[ 　]/)
    return eff_array
  end
  
  def ret_target_effect_hash(enum, eff_str)
    r_hash = Hash.new
    
    if eff_str == ""
      eff_array = Array.new
    else
      eff_array = ret_eff_array(eff_str)
    end
    
    rivals = ret_skill_with_effect_hash(enum,:rivals, eff_array)
    ours = ret_skill_with_effect_hash(enum,:ours, eff_array)
    
    r_hash[:rivals] = rivals
    r_hash[:ours] = ours
    
    return r_hash
  end
 
  def ret_skill_with_effect_hash(enum, key, eff_array)
    
    skill_seq_hash = ret_skill_sequence_hash(enum)
    skill_hash = Hash.new
    
    skill_seq_hash[key][:skill].each {|subarray|
      subarray.each_with_index {|elem,idx|
        if idx == 0 or idx == 1
        # nothing
        else
          elem.split(/、/).each {|skill|
            skill_hash.inc_num(skill, 1)
          }
        end
      }
    }
    
    skill_data_hash = @sk.ret_skill_name_hash_from_local
    skill_eff_hash = skill_data_hash[:effect]
    skill_sp_hash = skill_data_hash[:sp]
    
    regexs = Array.new
    eff_array.each {|estr|
      regexs << Regexp.new(estr)
    }
    
    # p skill_eff_hash
    r_hash = Hash.new
    skill_hash.each {|skill, freq|
      if skill_eff_hash.has_key?(skill)
        effect_disps = skill_eff_hash[skill]
        effect_disp = effect_disps.join(",")
        sp_cost = skill_sp_hash[skill]
        
        regexs.each {|eff|
          if effect_disp =~ eff
            effect_disp.gsub!(eff) {|match|
              "<u>" + match + "<\/u>"
            }
          end
        }
        sp_str = "SP消費 #{sp_cost.join(",")} "
        r_hash[skill] =  sp_str + effect_disp
        
      end
    }
    return r_hash
  end
  
  def ret_skill_sequence_hash(enum)
    r_hash = Hash.new
    our_team = ret_our_team_name(enum)
    unless our_team == nil
      rivals = ret_rival_name_array(enum)
      current_rivals = rivals.last
      
      r_hash[:ours] = Hash.new
      r_hash[:rivals] = Hash.new
      r_hash[:ours][:name] = our_team
      r_hash[:rivals][:name] = current_rivals
      
      our_skills = ret_skill_sequence_array(our_team)
      r_hash[:ours][:skill] = our_skills
      rival_skills = ret_skill_sequence_array(current_rivals)
      r_hash[:rivals][:skill] = rival_skills
    end
    return r_hash
  end
  
  def ret_skill_sequence_array(team_name)
    r_array = Array.new
    if @team_name_to_battle_file_hash.has_key?(team_name)
      files = @team_name_to_battle_file_hash[team_name]
      if @team_member_names_hash.has_key?(team_name)
        @team_member_names_hash[team_name].keys.each {|name|
          round = 1
          files.each {|file|
            if @used_skill_hash.has_key?(file) and file !~ /create/
              sklhash = @used_skill_hash[file]
              round_lines = Array.new
              round_lines << name
              round_lines << round
              ll = ret_one_agent_skill_sequence_array(name,sklhash)
              ll.each {|rline|
                round_lines << rline
              }
              r_array << round_lines
              round += 1
            end
          }
        }
      end
    end
    return r_array
  end
  
  def ret_one_agent_skill_sequence_array(name, skill_hash)
    r_array = Array.new
    skill_hash.each {|turn_num, name_hash|
      if name_hash.has_key?(name)
        skill_array = name_hash[name]
        each_turn_array = Array.new
        skill_array.each_with_index {|skill,idx|
          each_turn_array << skill
        }
        r_array << each_turn_array.join("、")
      end
    }
    return r_array
  end
  
  def ret_rival_name_array(enum)
    our_team = ret_our_team_name(enum)
    if @team_name_to_rivals_hash.has_key?(our_team)
      return @team_name_to_rivals_hash[our_team]
    else
      return []
    end
  end
  
  def ret_team_hash(file)
    team_hash = Hash.new
    io = open(file)
    while line = get_line(io)
      if line =~ /<I\sCLASS=Y3B>0勝<\/I><BR><I\sCLASS=[BR]5><U>(.*?)<\/U><\/I><BR>/
        team_name = $1
        while line2 = get_line(io)
          if line2 =~ /<A\sHREF="\.\.\/k\/k(\d+)\.html"\sTARGET=.+?>\((\d+)\)<\/A>.*?<BR>/
            num1 = $1
            num2 = $2
            if num1 == num2
              team_hash.push_array(team_name, num1)
            end
          elsif line2 =~ /^<\/TD>/
            break
          end
        end
      end
    end
    io.close
    return team_hash
  end
  
  def set_index_match_hashs
    @index_files.each {|file|
      teams_hash, battle_file_hash = ret_battle_file_hashs(file)
      @index_teams_hash[file] = teams_hash
      @index_match_file_hash[file] = battle_file_hash
    }
  end
  
  def set_team_member_name_hash
    @index_teams_hash.each {|file, teams_hash|
      if @index_match_file_hash.has_key?(file)
        battle_file_hash = @index_match_file_hash[file]
        teams_hash.each {|match_num, team_hash|
          if battle_file_hash.has_key?(match_num)
            filename = battle_file_hash[match_num]
            tpath= "#{@pool_dir}/#{filename}"
            STDERR.puts "#{tpath}"
            team_hash_rr = ret_team_member_names_hash(tpath)
            team_hash_rr.each {|team_name, array|
              array.each {|member_name|
                unless @team_member_names_hash.has_key?(team_name)
                  @team_member_names_hash[team_name] = Hash.new
                end
                @team_member_names_hash[team_name].inc_num(member_name,1)
              }
            }
          end
        }
      end
    }
  end

  def ret_cancel_target_file_array
    r_array = Array.new
    @index_teams_hash.each {|file, teams_hash|
      if @index_match_file_hash.has_key?(file)
        battle_file_hash = @index_match_file_hash[file]
        teams_hash.each {|match_num, team_hash|
          if battle_file_hash.has_key?(match_num)
            filename = battle_file_hash[match_num]
            tpath= "#{@pool_dir}/#{filename}"
            r_array << tpath
          end
        }
      end
    }
    return r_array
  end
  
  def set_gl_cancel_hash
    
    target_files = ret_cancel_target_file_array
    
    @gl_catch_skill_hash = Hash.new
    @gl_name_hash = Hash.new
    @gl_team_hash = Hash.new
    
    # p @team_member_names_hash
    # p @team_name_hash
    # p @char_enum_name_hash
    # target_files = ["../data/r068/br/6-385-2267.html"]
    
    target_files.each {|file|
      
      team_hash = Hash.new
      team_hash_r = Hash.new
      name_hash = Hash.new
      team_index = 0
      name_index = 0
      name_color_array = Array.new
      
      io = open(file)
      while line = get_line(io)
        
        if line =~ /<BR>　<B\sCLASS=W6i>試合を開始！<\/B><BR><BR><BR>/
          while line2 = get_line(io)
            if line2 =~ /<U\sCLASS=[BR]5i>(.+?)<\/U><BR><BR>/
              team_name = $1
              line3 = get_line(io)
              line3.scan(/>ENo\.(\d+?)<BR>/) {|match|
                team_hash.push_array(team_name, match.first)
                team_hash_r[match.first] = team_name
              }
            elsif line2 == "<BR>"
              break
            end
          end
        end
        
        if line =~ /<I\sCLASS=(.3B)>(.+?)\sは以下を装備！<\/I><BR>/
          
          class_str = $1
          name = $2
          name.gsub!(/<.*?>/,"")
          
          if name_color_array.size > 0
            if name_color_array.last != class_str
              team_index = 1
              name_index = 0
            end
          end
          name_color_array << class_str
          
          key = team_hash.keys[team_index]
          enum = team_hash[key][name_index]
          name_hash.push_array(name, enum)
          # p name, name_color_array, team_index, name_index
          name_index += 1
        end
        
        if line =~ /<I\sCLASS=Y5>(.+?)によって(.*?)が封殺された！<\/I><BR>/
          name = $1
          skill = $2
          
          name.gsub!(/<.*?>/,"")
          @gl_catch_skill_hash.inc_num(skill,1)
          
          if name_hash.has_key?(name)
            if name_hash[name].size == 1
              enum1 = name_hash[name].first
              team1 = team_hash_r[enum1]
              @gl_team_hash.inc_num(team1,1)
              @gl_name_hash.inc_num(enum1,1)

              if enum1 == nil or team1 == nil
                p "Empty"
                p name_hash, team_hash,file
                exit
              end
            else
              p "ERR0R1"
              p file
              p name_hash
            end
          else
            p "name_lost",name,name_hash
          end
        end
      end
      io.close
    }
    
  end

  def show_gl_name_hash
    @gl_name_hash.return_sorted_array.reverse.each {|c|
      puts "#{c[0]},#{c[1]}"
    }
  end

  def show_gl_team_hash
    @gl_team_hash.return_sorted_array.reverse.each {|c|
      puts "#{c[0]},#{c[1]}"
    }
  end

  def show_gl_catch_skill_hash
    @gl_catch_skill_hash.return_sorted_array.reverse.each {|c|
      puts "#{c[0]},#{c[1]}"
    }
  end
  
  def catch_skill(cstr)
    
    target_files = ret_cancel_target_file_array
    
    target_files.each {|file|
      
      io = open(file)
      while line = get_line(io)
        if line =~ /#{cstr}/
          p file, line
        end
      end
      io.close
    }
    
  end
  
  def set_used_skill_hash
    if @used_skill_hash == nil
      @used_skill_hash = Hash.new
    end
    
    @index_teams_hash.each {|file, teams_hash|
      if @index_match_file_hash.has_key?(file)
        STDERR.puts "Analysis #{file}"
        battle_file_hash = @index_match_file_hash[file]
        teams_hash.each {|match_num, team_hash|
          if battle_file_hash.has_key?(match_num)
            filename = battle_file_hash[match_num]
            tpath= "#{@pool_dir}/#{filename}"
            STDERR.puts "Extract uesed skill in #{tpath}"
            skill_hash = ret_used_skill_hash(tpath)
            # p skill_hash
            @used_skill_hash[filename] = skill_hash
          end
        }
      end
    }
  end
  
  def ret_battle_file_hashs(file)
    r_hash = Hash.new
    b_hash = Hash.new
    io = open(file)
    while line0 = get_line(io)
      if line0 =~ /CLASS=Y5i>(第\d+試合)<BR><\/TD>/
        match_num = $1
        team_hash = Hash.new
        while line = get_line(io)
          if line =~ /<I\sCLASS=Y3B>\d勝<\/I><BR><I\sCLASS=[BR]5><U>(.*?)<\/U><\/I><BR>/
            team_name = $1
            while line2 = get_line(io)
              if line2 =~ /<A\sHREF="\.\.\/k\/k(\d+)\.html"\sTARGET=.+?>\((\d+)\)<\/A>.*?<BR>/
                num1 = $1
                num2 = $2
                if num1 == num2
                  team_hash.push_array(team_name, num1)
                end
              elsif line2 =~ /<\/TD><TD\s.*?CLASS=Y5>V\sS<\/TD>/
                break
              elsif line2 =~ /^<\/TD>.*?<A\sHREF="(.+?.html)">V\sS<\/A><\/TD>/
                filename = $1
                b_hash[match_num] = filename
                break
              elsif line2 =~ /^<\/TD><\/TR><\/TABLE>/
                break
              end
            end
          elsif line =~ /^<\/DIV><\/TD><\/TR><\/TABLE>/
            r_hash[match_num] = team_hash
            break
          end
        end # while
      end
    end
    io.close
    return r_hash, b_hash
  end
  
  def ret_team_member_names_hash(file)
    
    team_hash = Hash.new
    team_hash_rr = Hash.new
    
    io = open(file)
    while line = get_line(io)
      if line =~ /<BR>　<B\sCLASS=W6i>試合を開始！<\/B><BR><BR><BR>/
        while line2 = get_line(io)
          if line2 =~ /<U\sCLASS=[BR]5i>(.+?)<\/U><BR><BR>/
            team_name = $1
            line3 = get_line(io)
            line3.scan(/>ENo\.(\d+?)<BR>/) {|match|
              team_hash.push_array(team_name, match.first)
            }
          elsif line2 == "<BR>"
            break
          end
        end
      elsif line =~ /<B>Turn\s1<\/B><\/TD><\/TR><\/TABLE>/
        line_count = 0
        while line2 = get_line(io)
          if line2 =~/<TABLE.*WIDTH=25>列<\/TD>.*>PSP<\/TD><\/TR>/
            line_count += 1
          elsif line2 =~ /^<TR/
            line2.scan(/<TD\sCLASS=.+?>[前中後]<\/TD><TD.*?>(.*?)<\/TD>/) {|match|
              tmp_name = match.first
              tmp_name.gsub!(/<.*?>/,"")
              key = team_hash.keys[line_count-1]
              team_hash_rr.push_array(key, tmp_name)
            }
          elsif line2 =~ /<\/TABLE>/ and line_count == 2
            break
          end
        end
      end
    end
    io.close
    return team_hash_rr
  end
  
  def ret_used_skill_hash(file)
    
    skill_hash = Hash.new
    turn_num = 0
    
    io = open(file)
    while line = get_line(io)
      if line =~ /<B>Turn\s*(\d+)\s*<\/B>/
        turn_num += 1
        skill_hash[turn_num] = Hash.new
      elsif is_acion_lines?(line)
        # 正規表現が長いので IkkiLineUtil のmoduleにした
        # STDERR.puts "in #{line}"
        
        name = ret_actions_agent(line)
        name.gsub!(/<.*?>/,"")
        while line2 = get_line(io)
          if line2 =~ /必殺技が発動/
            while line3 = get_line(io)
              if line3 =~ /<B\s.*?>(.*?)<\/B>/
                skill = $1
                skill_hash[turn_num].push_array(name,skill+"(必殺技)")
                break
              end
            end
            break
          elsif line2 =~ /<B\sCLASS\=[^F]+?>(.*?)！！<\/B>/ or line2 =~ /(通常攻撃)/
            skill = $1
            skill_hash[turn_num].push_array(name,skill)
            break
          end
        end
      end
    end
    io.close
    return skill_hash
  end
  
end

