class Hash
  
  def each_sorted_key_value_reverse(i=1)
    self.return_sorted_array(i).reverse.each {|c|
      yield(c[0],c[1])
    }
  end
  
  def each_sorted_key_value(i=1)
    self.return_sorted_array(i).each {|c|
      yield(c[0],c[1])
    }
  end
  
  def printIncNumKeyValue(i=1)
    self.return_sorted_array(i).reverse.each {|c|
      puts "#{c[0]} #{c[1]}"
    }
  end

  def printIncNumKeyValueAndTotal(i=1)
    t = 0
    self.return_sorted_array(i).reverse.each {|c|
      t += c[1].to_i
    }
    self.return_sorted_array(i).reverse.each {|c|
      puts "#{c[0]} #{c[1]} #{c[1]/t.to_f}"
    }
    puts t
  end
  
  def push_hash_and_inc_num(key,value)
    unless self.has_key?(key)
      self[key] = Hash.new
    end
    self[key].inc_num(value,1)
  end
  
  def push_array2(key,value)
    if self.has_key?(key) && self[key].kind_of?(Array)
      self[key] << value
      if value.kind_of?(Array)
	self[key].flatten!
      end
    else
      tmpArray = Array.new
      tmpArray << value
      if value.kind_of?(Array)
	tmpArray.flatten!
      end
      self[key] = tmpArray
    end
  end

  def push_array(key,value)
    if self.has_key?(key)
      if self[key].kind_of?(Array)
	self[key] << value
      else
	tmpArray = Array.new
	tmpArray << self[key]
	tmpArray << value
	self[key] = tmpArray
      end
    else
      tmpArray = Array.new
      tmpArray << value
      self[key] = tmpArray
    end
  end

  def inc_num(key,num)
    if self.has_key?(key) && self[key].kind_of?(Numeric)
      self[key] += num
    else
      self[key] = num
    end
  end

  def key_of_the_value(value)
    self.each {|key,array|
      if array.index(value) != nil
        return key
      end
    }
    return nil
  end
  
  def value_array_uniq!()
    self.each {|key,value|
      if value.kind_of?(Array)
        value.uniq!
      end
    }
  end

  def return_sorted_array(i=1)
    array = self.to_a.sort {|a,b|
      a[i] <=> b[i]
    }
    if array == nil
      return Array.new
    end
    return array
  end
end
