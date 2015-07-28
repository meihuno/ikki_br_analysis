# -*- coding: utf-8 -*-
require 'find'

module IkkiFileUtil
  
  def ret_newest_k_dir(bdir="../data")
    pool_dir = bdir + "\/**"
    rdirs = Dir.glob(pool_dir)
    dir = rdirs.sort.last
    tdir = dir + "/k"
    return tdir
  end

  def ret_newest_br_dir(bdir="../data")
    pool_dir = bdir + "\/**"
    rdirs = Dir.glob(pool_dir)
    dir = rdirs.sort.last
    tdir = dir + "/br"
    return tdir
  end
  
  def ret_newest_base_dir(bdir="../data")
    pool_dir = bdir + "\/**"
    rdirs = Dir.glob(pool_dir)
    rdirs.delete_if {|file|
      if file !~ /\d$/
        true
      end
    }
    dir = rdirs.sort.last
    return dir
  end
  
  def ret_index_files(tdir)
    result_array = Array.new
    Find.find(tdir) {|path|
      if path =~ /\.html$/
        # p path
        if path =~ /index\d+\.html/
          unless path =~ /#/
            result_array << path
          end
        end
      end
    }
    return result_array
  end

  def ret_k_files(tdir)
    result_array = Array.new
    Find.find(tdir) {|path|
      if path =~ /\.html$/
        # p path
        if path =~ /k\d+\.html/
          unless path =~ /#/
            result_array << path
          end
        end
      end
    }
    return result_array
  end
  
end
