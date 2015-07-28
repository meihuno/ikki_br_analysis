# coding: utf-8
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'zaru_hash'
require 'kconv'
require 'ikki_fantasy_analysis'
require 'pstore'
require 'optparse'

opt = OptionParser.new

option={:ver => "r068", :new => false}
OptionParser.new do |opt|
  opt.on('--new','データベースを新規作成') {|v|
    option[:new] = true
  }
  opt.on('-v [VALUE]','更新回指定、デフォルトは056') {|v|
    option[:ver] = v
  }
  
  opt.parse!(ARGV)
end

ver = option[:ver]
new_flag = option[:new]

ikki_box = IkkiFantasyAnalysis.new("../data")
verdir = ikki_box.base_dir
ver = verdir.split(/[\/\\]/).last
p "./data/ikki_box_#{ver}"

if File.exist?("./data/ikki_box_#{ver}") and new_flag == false
  STDERR.puts "Loading ikki_box_#{ver}"
  db = PStore.new("./data/ikki_box_#{ver}")
  db.transaction{|pstore|
    ikki_box = pstore["br"]
  }  
else
  ikki_box.set_team_name_hash
  ikki_box.set_index_match_hashs
  ikki_box.set_team_member_name_hash
  ikki_box.set_used_skill_hash
  ikki_box.set_rival_name_hash
  ikki_box.set_char_skgif_hash
  ikki_box.set_char_enum_name_hash
  
  db = PStore.new("./data/ikki_box_#{ver}")
  STDERR.puts "Saving ikki_box_#{ver}"
  db.transaction{|pstore|
    pstore["br"] = ikki_box
  }
end

# ikki_box.set_char_enum_name_hash
ikki_box.set_gl_cancel_hash
puts "ENo, 封殺数"
ikki_box.show_gl_name_hash
puts "パーティ名, 封殺数"
ikki_box.show_gl_team_hash
puts "スキル名, 封殺数"
ikki_box.show_gl_catch_skill_hash

=begin
STDERR.puts "Saving ikki_box_#{ver}"
db = PStore.new("./data/ikki_box_#{ver}")
db.transaction{|pstore|
  pstore["br"] = ikki_box
}
=end
