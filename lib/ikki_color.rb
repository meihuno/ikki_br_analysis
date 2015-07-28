class IkkiColor
  attr_accessor :color_five_hash
  def initialize
    set_color_hash
  end

  def set_color_hash
    @color_five_hash = Hash.new
    
    blues = Hash.new
    blues["lightsteelblue"] ="#b0c4de"
    blues["steelblue"] = "#4682b4"
    
    reds = Hash.new
    reds["pink"] ="#ffc0cb"
    reds["thistle"] = "#d8bfd8"
    
    yellows = Hash.new
    yellows["papayawhip"] = "#ffefd5"

    greens = Hash.new
    greens["darkseagreen"] = "#8fbc8f"

    others = Hash.new
    others["silver"] = "#C0C0C0"
    
    @color_five_hash[:red] = reds
    @color_five_hash[:blue] = blues
    @color_five_hash[:yellow] = yellows
    @color_five_hash[:green] = greens
    @color_five_hash[:others] = others
    
  end
end
