# coding: utf-8
$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'zaru_hash'
require 'kconv'
require 'ikki_fantasy_analysis'
require 'pstore'
require 'find'
require 'logger'
require 'ikki_color'

require 'bundler'
Bundler.require
# require 'sinatra'
# require 'sinatra/reloader'
include HTML

ikki_box = nil
colors = IkkiColor.new

targets = Array.new
Find.find("./data") {|path|
  if path =~ /ikki_box_r\d+$/
    targets << path
  end
}

log = Logger.new(STDERR)

file = targets.last
if File.exist?(file)
  STDERR.puts "Loading #{file}"
  db = PStore.new(file)
  db.transaction{|pstore|
    ikki_box = pstore["br"]
  }
end

def ret_table(array)
  table = ret_table_object(array)
  return table.html
end

def ret_table_object(array)
  # You can set physical tags inline using block syntax...
  table = Table.new do
    align    'left'
    bgcolor  'red'

    head_array = ["名前","N回戦"]
    for i in 1 .. 10
      head_array << "Turn#{i}"
    end

    row_contents = []
    
    array.each {|each_line|
      tmp_array = Array.new
      each_line.each_with_index {|elem, idx|
        tmp_array << elem.to_s
        if idx == 11
          break
        end
      }
      row_contents << tmp_array
    }
    
    header [ head_array ]
    row_contents.each {|row|
      content  [row]
    }
    
  end
  return table
end

def ret_eff_color(tary, eff_hash, eff_color)
  match_flag = false
  tary.each {|tstr|
    if eff_hash.has_key?(tstr)
      eff_disp = eff_hash[tstr]
      eff_disp.scan(/<u>(.*?)<\/u>/) {|match|
        cstr = match.first
        color = eff_color[cstr]
        return color
      }
      match_flag = true
    end
  }
  if match_flag == true
    return '#FFFFFF'
  else
    return nil
  end
end

def ret_table_with_eff_str(array, eff_hash, eff_color)
  table = ret_table_object(array)
  
  table.each {|row|
    row.each {|td|
      tstr = td.content
      tary = tstr.split(/、/)
      tary.uniq!
      
      tmp_color = ret_eff_color(tary, eff_hash, eff_color)
      unless tmp_color == nil
        td.bgcolor = tmp_color
      end
    }
    
  }
  table_html = table.html
  doc = Hpricot(table_html)
  doc.search("//td[@bgcolor]").each {|td|
    text_array = Array.new
    text = td.inner_text
    tmp_array = text.split(/、/)
    tmp_array.uniq!
    tmp_array.each {|tstr|
      
      if eff_hash.has_key?(tstr)
        disp_str = eff_hash[tstr]
        text_array << "#{tstr}@#{disp_str}"
      end
    }
    td["id"] = "sample"
    td["data-text"] = text_array.join("<br>")
  }
  table_html = doc.to_html
  return table_html
end

def ret_table_with_eff_str_legacy(array, eff_hash, eff_color)
  table = ret_table_object(array)
  table.each {|row|
    row.each {|td|
      tstr = td.content
      tary = tstr.split(/、/)
      match_flag = false
      tmp_color = ret_eff_color(tary, eff_hash, eff_color)
      unless tmp_color == nil
        td.bgcolor = tmp_color
      end
    }
  }
  table_html = table.html
  doc = Hpricot(table_html)
  doc.search("//td[@bgcolor]").each {|td|
    text_array = Array.new
    text = td.inner_text
    tmp_array = text.split(/、/)
    tmp_array.uniq!
    tmp_array.each {|tstr|
      if eff_hash.has_key?(tstr)
        disp_str = eff_hash[tstr]
        text_array << "#{tstr}@#{disp_str}"
      end
    }
    td["id"] = "sample"
    td["data-text"] = text_array.join("<br>")
  }
  table_html = doc.to_html
  return table_html
end

def ret_eff_color_hash(eff_array, colors)
  eff_color_hash = Hash.new
  if eff_array.size == 0
    return eff_color_hash
  end
  count = 0
  cfv_hash = colors.color_five_hash
  eff_array.each {|estr|
    if count > 3
      bkey = :others
    else
      bkey = cfv_hash.keys[count]
    end
    bckey = cfv_hash[bkey].keys.first
    tmp_color = cfv_hash[bkey][bckey]
    eff_color_hash[estr] = tmp_color
    count += 1
  }
  return eff_color_hash
end

before do
  @tables = Array.new
end

get '/' do
  erb :index
end

# POST
post '/show' do
  begin
    enum = params[:enum]
    eff_str = params[:effect]
    show_flag = params[:rival_only]
    
    if enum =~ /^\d+$/
      
      r_hash = ikki_box.ret_skill_sequence_hash(enum)
      
      if r_hash.empty?
        @tables << "not found"
      else
        
        eff_hash = ikki_box.ret_target_effect_hash(enum, eff_str)
        
        r_hash.each {|side,skills|
          if show_flag == "1" and side == :ours
            next
          end
          
          if side == :ours
            side_str = "Yours"
          elsif side == :rivals
            side_str = "Rivals"
          end
          
          @tables << "#{side_str} #{skills[:name]}"
          
          sks = skills[:skill]
          effs = eff_hash[side]
          if eff_str == ""
            eff_array = Array.new
          else
            eff_array = ikki_box.ret_eff_array(eff_str)
          end
          eff_color = ret_eff_color_hash(eff_array, colors)
          stbl = ret_table_with_eff_str(sks,effs,eff_color)
          
          @tables << stbl
        }
      end
    else
      @tables << "not found"
    end
    
    # @tables << table.html
    erb :index
    # redirect '/'
  rescue => ex
    STDOUT.puts ex.message
    log.fatal("Caught exception; exiting")
    log.fatal(ex)
    redirect '/'  
  end
  
end
