# coding: utf-8
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'zaru_hash'
require 'kconv'
require 'ikki_fantasy_analysis'
require 'pstore'
require 'optparse'
require "readline"

opt = OptionParser.new

option={:ver => "r068", :new => false}
OptionParser.new do |opt|
  opt.on('--new','データベースを新規作成') {|v|
    option[:new] = true
  }
  opt.on('-v [VALUE]','更新回指定、デフォルトは068') {|v|
    option[:ver] = v
  }
  
  opt.parse!(ARGV)
end

ver = option[:ver]
new_flag = option[:new]

ikki_box = IkkiFantasyAnalysis.new("../data")
verdir = ikki_box.base_dir
ver = verdir.split(/[\/\\]/).last

# p "./data/ikki_box_#{ver}"

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
  
  db = PStore.new("./data/ikki_box_#{ver}")
  STDERR.puts "Saving ikki_box_#{ver}"
  db.transaction{|pstore|
    pstore["br"] = ikki_box
  }
end

ikki_box.set_char_skgif_index_hash

while buf = Readline.readline("> ", true)
  str = buf
  input_array = str.split(/[ 　]/)
  out_array = ikki_box.serach_skgif(input_array)
  p input_array
  print "-> ", out_array.join(", "), "\n"
end

=begin
p ikki_box.serach_skgif(["閃天","ゲヘナ"])
p ikki_box.serach_skgif(["閃天","ゲヘナ","フエンテ"])
p ikki_box.serach_skgif(["ゲヘナ","フエンテ"])
p ikki_box.serach_skgif(["超INTUP"])
p ikki_box.serach_skgif(["閃天"])
p ikki_box.serach_skgif(["閃天:2"])
p ikki_box.serach_skgif(["閃天:3"])
p ikki_box.serach_skgif(["閃天:4"])
p ikki_box.serach_skgif(["一片氷心","フロス"])
p ikki_box.serach_skgif(["エスピラール","フロス"])
p ikki_box.serach_skgif(["サニュイス","フロス"])
p ikki_box.serach_skgif(["鏡花水月","フロス"])
p ikki_box.serach_skgif(["エネドラ","フロス"])
p ikki_box.serach_skgif(["アサシンコール","フロス"])
p ikki_box.serach_skgif(["ファウダー","フロス"])
p ikki_box.serach_skgif(["ニュートリエント","フロス"])
p "---"
p ikki_box.serach_skgif(["閃天","サニュイス","冥土の歳暮","ドロフォノス"])
p ikki_box.serach_skgif(["閃天","サニュイス","冥土の歳暮","フロス"])
p ikki_box.serach_skgif(["閃天","サニュイス","冥土の歳暮","フロス","クリシス"])
p ikki_box.serach_skgif(["閃天","サニュイス","ウルティオ"])
p ikki_box.serach_skgif(["逆波"])
p ikki_box.serach_skgif(["死灰復燃"])
p ikki_box.serach_skgif(["不死鳥"])
p ikki_box.serach_skgif(["不死鳥","死灰復燃"])
=end
