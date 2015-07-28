# coding: utf-8
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'zaru_hash'
require 'kconv'
require 'ikki_fantasy_analysis'
require 'test-unit'
require 'pstore'

class TestIkkiFantasyAnalysis < Test::Unit::TestCase

  def setup
    option={:ver => "r068", :new => false}
    ver = option[:ver]
    new_flag = option[:new]
    
    @ikki_box = nil
    
    if File.exist?("./data/ikki_box_#{ver}") and new_flag == false
      
      STDERR.puts "Loading ikki_box_#{ver}"
      db = PStore.new("./data/ikki_box_#{ver}")
      db.transaction{|pstore|
      @ikki_box = pstore["br"]
      }
    else
      
      @ikki_box.set_team_name_hash
      @ikki_box.set_index_match_hashs
      @ikki_box.set_team_member_name_hash
      @ikki_box.set_used_skill_hash
      @ikki_box.set_rival_name_hash
      @ikki_box.set_char_skgif_hash
      @ikki_box.set_char_enum_name_hash
      
      db = PStore.new("./data/ikki_box_#{ver}")
      STDERR.puts "Saving ikki_box_#{ver}"
      db.transaction{|pstore|
        pstore["br"] = @ikki_box
      }
    end
    
  end
  
  def test_team_name_hash
    
    team_name = "あなたの背後に這い寄り隊"
    assert_equal(@ikki_box.team_name_hash.has_key?(team_name), true)
    my_team = @ikki_box.team_name_hash[team_name]
    assert_equal(my_team.include?("510"),true)
    assert_equal(my_team.include?("523"),true)
    assert_equal(my_team.include?("1523"),true)
    assert_equal(my_team.include?("2408"),true)
    
  end
  
  def test_team_member_names_hash
    
    team_name = "あなたの背後に這い寄り隊"
    assert_equal(@ikki_box.team_member_names_hash.has_key?(team_name), true)
    my_team = @ikki_box.team_member_names_hash[team_name]

    assert_equal(my_team.has_key?("ゼゼ"),true)
    assert_equal(my_team.has_key?("チャット"),true)
    assert_equal(my_team.has_key?("とかげ"),true)
    assert_equal(my_team.has_key?("シュガー"),true)
    
  end
  
  def test_used_skilled_hash

    team_name = "あなたの背後に這い寄り隊"
    
    assert_equal(@ikki_box.team_name_to_battle_file_hash.has_key?(team_name), true)
    battle_files = @ikki_box.team_name_to_battle_file_hash[team_name]
    
    bfile = battle_files.last
    used_skill_hash = @ikki_box.used_skill_hash
    
    assert_equal(used_skill_hash.has_key?(bfile), true)
    skill_seq_hash = @ikki_box.used_skill_hash[bfile]
    skill_seq_hash.each {|turn, skill_hash|
      if skill_hash.has_key?("シュガー")
        skill_seq = skill_hash["シュガー"] 
        if turn == 10
          assert_equal(skill_seq.first, "フロス")
        end
      end
    }
  end

  
  def test_ret_skill_sequence_hash
    
    enum = "1523"
    r_hash = @ikki_box.ret_skill_sequence_hash(enum)
    assert_equal(r_hash.has_key?(:ours), true)
    assert_equal(r_hash.has_key?(:rivals), true)

    ours_skills = r_hash[:ours]
    assert_equal(ours_skills.has_key?(:skill), true)
    skill_lines = ours_skills[:skill]
    skill_lines.each {|skill_line|
      if skill_line.first == "シュガー"
        round = skill_line[1]
        
        case round
        when 1
          skill_check = skill_line.grep(/グローム/)
          assert_equal(skill_check.empty?, false)
        when 2
          skill_check = skill_line.grep(/冥土の歳墓/)
          assert_equal(skill_check.empty?, false)
        when 3
          skill_check = skill_line.grep(/冥土の歳墓/)
          assert_equal(skill_check.empty?, false)
        when 4
          skill_check = skill_line.grep(/クリシス/)
          assert_equal(skill_check.empty?, false)
        when 5
          skill_check = skill_line.grep(/トワイライト/)
          assert_equal(skill_check.empty?, false)
        when 6
          skill_check = skill_line.grep(/サニュイス/)
          assert_equal(skill_check.empty?, false)
        when 7
          ## なすすべなく敗退。技もふれなかった。
          assert_equal(ours_skills.size, 2)
        when 8
          skill_check = skill_line.grep(/フロス/)
          assert_equal(skill_check.empty?, false)
          
        end
      end
    }
  end

  def test_ret_character_skil
    
    # ikki_box.set_used_skill_hash
    r_hash = @ikki_box.ret_target_effect_hash("1523", "シールド　回復")
    assert_equal(r_hash.has_key?(:ours), true)
    assert_equal(r_hash.has_key?(:rivals), true)
    
    r_hash[:ours].each {|line|
      assert_equal(line.size,2)
      if line.last =~ /<u>(.+?)<\/u>/
        cstr = $1
        assert_not_nil(cstr.match(/シールド|回復/))
      end
    }

    r_hash2 = @ikki_box.ret_target_effect_hash("1523", "シールド 回復")
    assert_equal(r_hash2.has_key?(:ours), true)
    assert_equal(r_hash2.has_key?(:rivals), true)
    
    r_hash2[:ours].each {|line|
      assert_equal(line.size,2)
      if line.last =~ /<u>(.+?)<\/u>/
        cstr = $1
        assert_not_nil(cstr.match(/シールド|回復/))
      end
    }
    
  end
  
end
