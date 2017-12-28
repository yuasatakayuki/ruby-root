require "RubyROOT"
require "colorable"

DEFAULT_CANVAS_WIDTH = 600
DEFAULT_CANVAS_HEIGHT = 600
DEFAULT_FONT = 43 # Helvetica
DEFAULT_FONT_SIZE = 16
DEFAULT_FONT_SIZE_TITLE = 18

Root.gROOT.SetStyle("Plain")
Root.gStyle.SetOptStat(0)
Root.gStyle.SetTitleFont(DEFAULT_FONT, "t")
Root.gStyle.SetTitleSize(DEFAULT_FONT_SIZE, "t")
Root.gStyle.SetTitleBorderSize(0) # No border around title

Root.gStyle.SetLegendFont(43)
if Root.gStyle.respond_to?(:SetLegendTextSize)
  Root.gStyle.SetLegendTextSize(DEFAULT_FONT_SIZE)
end

Root.gStyle.SetTitleAlign(12)
Root.gStyle.SetTitleX(0.1)
Root.gStyle.SetTitleY(0.925)
Root.gStyle.SetTitleW(0.85)
Root.gStyle.SetTitleH(0.05)

Root.gStyle.SetGridWidth(1)
Root.gStyle.SetGridStyle(3)
Root.gStyle.SetGridColor(Root::KGray)

def to_double_array(array)
  result = Root::DoubleArray.new(array.length)
  array.each_with_index() { |e, i|
    result[i] = e
  }
  return result
end

def create_canvas(name = "c", title = "Canvas",
                  w = DEFAULT_CANVAS_WIDTH,
                  h = DEFAULT_CANVAS_HEIGHT)
  Root::TCanvas.create(name.to_s, title, w, h)
end

def create_legend(x1 = 0.7, y1 = 0.8, x2 = 0.9, y2 = 0.9)
  Root::TLegend.new(x1, y1, x2, y2)
end

def create_file(file_name)
  Root::TFile.open(file_name, "recreate")
end

def open_root_file(file_name, option = "")
  if option == "w"
    option = "recreate"
  end
  Root::TFile.open(file_name, option)
end

def close_root_file(file)
  file.Close()
end

module Root
  class TFile
    def get(name)
      self.Get(name.to_s)
    end
  end

  class TDirectoryFile
    def get(name)
      self.Get(name.to_s)
    end
  end
end

#---------------------------------------------
# Syntax sugar for plottable objects
#---------------------------------------------
module Root::Plottable
  def plot(option = "")
    self.Draw(option.to_s)
  end

  alias draw plot

  def xlabel(title, center = false)
    self.GetXaxis.SetTitle(title)
    self.GetXaxis.CenterTitle(center)
  end

  alias xtitle xlabel

  def ylabel(title, center = false)
    self.GetYaxis.SetTitle(title)
    self.GetYaxis.CenterTitle(center)
  end

  alias ytitle ylabel

  def zlabel(title, center = false)
    self.GetZaxis.SetTitle(title)
    self.GetZaxis.CenterTitle(center)
  end

  alias ztitle zlabel

  def xylabels(xtitle, ytitle)
    xlabel xtitle
    ylabel ytitle
  end

  alias xytitles xylabels
  alias xytitle xylabels

  def labels(xtitle, ytitle = "", ztitle = "")
    xlabel xtitle
    ylabel ytitle
    zlabel ztitle
  end

  def label(option)
    option.each do |k, v|
      if k.to_s.downcase.include?("x")
        xlabel(v)
      elsif k.to_s.downcase.include?("y")
        ylabel(v)
      end
    end
  end

  def xoffset(offset)
    self.GetXaxis.SetTitleOffset(offset)
  end

  alias xtitle_offset xoffset

  def yoffset(offset)
    self.GetYaxis.SetTitleOffset(offset)
  end

  alias ytitle_offset yoffset

  def zoffset(offset)
    self.GetZaxis.SetTitleOffset(offset)
  end

  alias ztitle_offset zoffset

  def xyoffset(x_offset, y_offset)
    xoffset x_offset
    yoffset y_offset
  end

  def xyzoffset(x_offset, y_offset, z_offset)
    xoffset x_offset
    yoffset y_offset
    zoffset z_offset
  end

  def removex()
    xoffset 999
    self.GetXaxis.SetLabelOffset 999
  end

  def center_label
    self.GetXaxis.CenterTitle
    self.GetYaxis.CenterTitle
    begin
      self.GetZaxis.CenterTitle
    rescue
    end
  end

  alias :center_title :center_label

  def font_size(size_in_pixel)
    font_size = size_in_pixel
    self.GetXaxis.SetLabelSize(font_size)
    self.GetXaxis.SetTitleSize(font_size)
    self.GetYaxis.SetLabelSize(font_size)
    self.GetYaxis.SetTitleSize(font_size)
    begin
      self.GetZaxis.SetLabelSize(font_size)
      self.GetZaxis.SetTitleSize(font_size)
    rescue
    end
    @font_size_manually_set = true
  end

  def font_size_set?
    if @font_size_manually_set
      true
    else
      false
    end
  end

  def font(font_style = "helvetica")
    font_style = font_style.to_s.downcase.split(" ")[0]
    case font_style
    when "helvetica" then font_style = 43
    when "times" then font_style = 133
    when "roman" then font_style = 133
    else
      puts "Error: font #{font_style} invalid"
      exit
    end
    self.GetXaxis.SetLabelFont(font_style)
    self.GetXaxis.SetTitleFont(font_style)
    self.GetYaxis.SetLabelFont(font_style)
    self.GetYaxis.SetTitleFont(font_style)
    begin
      self.GetZaxis.SetLabelFont(font_style)
      self.GetZaxis.SetTitleFont(font_style)
    rescue
    end
    # self.GetXaxis.SetTitleOffset(1)
    # self.GetYaxis.SetTitleOffset(1)
    font_size DEFAULT_FONT_SIZE if @font_size_manually_set != true
  end

  def line_width(width)
    self.SetLineWidth(width)
  end

  def marker(marker = "circle")
    n = 20
    marker = marker.to_s.downcase
    if marker.include?("open")
      marker.gsub("open", "").delete("_").strip!
      case marker
      when "circle" then n = 24
      when "square" then n = 25
      when "triangle" then n = 26
      end
    else
      marker.gsub("filled", "").delete("_").strip!
      case marker
      when "circle" then n = 20
      when "square" then n = 21
      when "triangle" then n = 22
      end
    end
    self.SetMarkerStyle(n)
  end

  def marker_size(size)
    self.SetMarkerSize(size)
  end

  @@color_map = {
    white: [255, 255, 255],
    whitesmoke: [245, 245, 245],
    ghostwhite: [248, 248, 255],
    aliceblue: [240, 248, 255],
    lavendar: [230, 230, 250],
    azure: [240, 255, 255],
    lightcyan: [224, 255, 255],
    mintcream: [245, 255, 250],
    honeydew: [240, 255, 240],
    ivory: [255, 255, 240],
    beige: [245, 245, 220],
    lightyellow: [255, 255, 224],
    lightgoldenrodyellow: [250, 250, 210],
    lemonchiffon: [255, 250, 205],
    floralwhite: [255, 250, 240],
    oldlace: [253, 245, 230],
    cornsilk: [255, 248, 220],
    papayawhite: [255, 239, 213],
    blanchedalmond: [255, 235, 205],
    bisque: [255, 228, 196],
    snow: [255, 250, 250],
    linen: [250, 240, 230],
    antiquewhite: [250, 235, 215],
    seashell: [255, 245, 238],
    lavenderblush: [255, 240, 245],
    mistyrose: [255, 228, 225],
    gainsboro: [220, 220, 220],
    lightgray: [211, 211, 211],
    lightsteelblue: [176, 196, 222],
    lightblue: [173, 216, 230],
    lightskyblue: [135, 206, 250],
    powderblue: [176, 224, 230],
    paleturquoise: [175, 238, 238],
    skyblue: [135, 206, 235],
    mediumaquamarine: [102, 205, 170],
    aquamarine: [127, 255, 212],
    palegreen: [152, 251, 152],
    lightgreen: [144, 238, 144],
    khaki: [240, 230, 140],
    palegoldenrod: [238, 232, 170],
    moccasin: [255, 228, 181],
    navajowhite: [255, 222, 173],
    peachpuff: [255, 218, 185],
    wheat: [245, 222, 179],
    pink: [255, 192, 203],
    lightpink: [255, 182, 193],
    thistle: [216, 191, 216],
    plum: [221, 160, 221],
    silver: [192, 192, 192],
    darkgray: [169, 169, 169],
    lightslategray: [119, 136, 153],
    slategray: [112, 128, 144],
    slateblue: [106, 90, 205],
    steelblue: [70, 130, 180],
    mediumslateblue: [123, 104, 238],
    royalblue: [65, 105, 225],
    blue: [0, 0, 255],
    dodgerblue: [30, 144, 255],
    cornflowerblue: [100, 149, 237],
    deepskyblue: [0, 191, 255],
    cyan: [0, 255, 255],
    aqua: [0, 255, 255],
    turquoise: [64, 224, 208],
    mediumturquoise: [72, 209, 204],
    darkturquoise: [0, 206, 209],
    lightseagreen: [32, 178, 170],
    mediumspringgreen: [0, 250, 154],
    springgreen: [0, 255, 127],
    lime: [0, 255, 0],
    limegreen: [50, 205, 50],
    yellowgreen: [154, 205, 50],
    lawngreen: [124, 252, 0],
    chartreuse: [127, 255, 0],
    greenyellow: [173, 255, 47],
    yellow: [255, 255, 0],
    gold: [255, 215, 0],
    orange: [255, 165, 0],
    darkorange: [255, 140, 0],
    goldenrod: [218, 165, 32],
    burlywood: [222, 184, 135],
    tan: [210, 180, 140],
    sandybrown: [244, 164, 96],
    darksalmon: [233, 150, 122],
    lightcoral: [240, 128, 128],
    salmon: [250, 128, 114],
    lightsalmon: [255, 160, 122],
    coral: [255, 127, 80],
    tomato: [255, 99, 71],
    orangered: [255, 69, 0],
    red: [255, 0, 0],
    deeppink: [255, 20, 147],
    hotpink: [255, 105, 180],
    palevioletred: [219, 112, 147],
    violet: [238, 130, 238],
    orchid: [218, 112, 214],
    magenta: [255, 0, 255],
    fuchsia: [255, 0, 255],
    mediumorchid: [186, 85, 211],
    darkorchid: [153, 50, 204],
    darkviolet: [148, 0, 211],
    blueviolet: [138, 43, 226],
    mediumpurple: [147, 112, 219],
    gray: [128, 128, 128],
    mediumblue: [0, 0, 205],
    darkcyan: [0, 139, 139],
    cadetblue: [95, 158, 160],
    darkseagreen: [143, 188, 143],
    mediumseagreen: [60, 179, 113],
    teal: [0, 128, 128],
    forestgreen: [34, 139, 34],
    seagreen: [46, 139, 87],
    darkkhaki: [189, 183, 107],
    peru: [205, 133, 63],
    crimson: [220, 20, 60],
    indianred: [205, 92, 92],
    rosybrown: [188, 143, 143],
    mediumvioletred: [199, 21, 133],
    dimgray: [105, 105, 105],
    black: [0, 0, 0],
    midnightblue: [25, 25, 112],
    darkslateblue: [72, 61, 139],
    darkblue: [0, 0, 139],
    navy: [0, 0, 128],
    darkslategray: [47, 79, 79],
    green: [0, 128, 0],
    darkgreen: [0, 100, 0],
    darkolivegreen: [85, 107, 47],
    olivedrab: [107, 142, 35],
    olive: [128, 128, 0],
    darkgoldenrod: [184, 134, 11],
    chocolate: [210, 105, 30],
    sienna: [160, 82, 45],
    saddlebrown: [139, 69, 19],
    firebrick: [178, 34, 34],
    brown: [165, 42, 42],
    maroon: [128, 0, 0],
    darkred: [139, 0, 0],
    darkmagenta: [139, 0, 139],
    purple: [128, 0, 128],
    indigo: [75, 0, 130],
  }

  def color(color, alpha = 1.0)
    if (color.instance_of?(String) or color.instance_of?(Symbol)) && !@@color_map[color.to_sym].nil?
      rgb = @@color_map[color.to_sym].map { |e| e / 255.0 }
      colorNumber = Root::TColor::GetColor(rgb[0], rgb[1], rgb[2])
      if alpha == 1.0
        self.SetLineColor(colorNumber)
        self.SetMarkerColor(colorNumber)
      else
        self.SetLineColorAlpha(colorNumber, alpha)
        self.SetMarkerColorAlpha(colorNumber, alpha)
      end
    else
      if alpha == 1.0
        self.SetLineColor(color)
        self.SetMarkerColor(color)
      else
        self.SetLineColorAlpha(color, alpha)
        self.SetMarkerColorAlpha(color, alpha)
      end
    end
  end

  def fill_color(color, alpha = 1.0)
    if !@@color_map[color].nil?
      rgb = @@color_map[color].map { |e| e / 255.0 }
      colorNumber = Root::TColor::GetColor(rgb[0], rgb[1], rgb[2])
      if alpha == 1.0
        self.SetFillColor(colorNumber)
      else
        self.SetFillColorAlpha(colorNumber, alpha)
      end
    else
      if alpha == 1.0
        self.SetFillColor(color)
      else
        self.SetFillColorAlpha(color, alpha)
      end
    end
  end

  def more_log_labels(option = "xy")
    option = option.to_s
    option.downcase!
    self.GetXaxis.SetMoreLogLabels() if option.include?("x")
    self.GetYaxis.SetMoreLogLabels() if option.include?("y")
  end

  def more_log_labels_x
    more_log_labels("x")
  end

  def more_log_labels_y
    more_log_labels("y")
  end

  def more_log_labels_xy
    more_log_labels("xy")
  end

  def no_exponent(option = "xyz")
    option = option.to_s
    option.downcase!
    self.GetXaxis.SetNoExponent() if option.include?("x")
    self.GetYaxis.SetNoExponent() if option.include?("y")
    begin
      self.GetZaxis.SetNoExponent() if option.include?("z")
    rescue
    end
  end

  def no_exponent_x
    no_exponent("x")
  end

  def no_exponent_y
    no_exponent("y")
  end

  def no_exponent_z
    no_exponent("z")
  end

  def save_as(file_name, draw_option = "", width = 600, height = 600)
    c = canvas(width, height)
    self.Draw(draw_option.to_s)
    c.SaveAs(file_name)
  end

  def range(x, y = [])
    if x.instance_of?(Array) && x.length == 2
      self.GetXaxis.SetRangeUser(x[0], x[1])
      if y.instance_of?(Array) && y.length == 2
        self.GetYaxis.SetRangeUser(y[0], y[1])
      end
    else
      if x.instance_of?(Integer) && !y.instance_of?(Array)
        x_lower = x.to_f
        x_upper = y.to_f
        self.GetXaxis.SetRangeUser(x_lower, x_upper)
      end
    end
  end

  def xrange(x_lower, x_upper = nil)
    self.GetXaxis.SetRangeUser(x_lower, x_upper)
  end

  def yrange(y_lower, y_upper)
    self.GetYaxis.SetRangeUser(y_lower, y_upper)
  end

  def zrange(z_lower, z_upper)
    self.GetYaxis.SetRangeUser(z_lower, z_upper)
  end

  def set(&block)
    Root.gStyle.SetTitleAlign(12)
    instance_eval(&block)
  end

  alias style set

  def style_clean
    font :helvetica
    font_size 15
    line_width 2
    color :teal
  end

  def title(title)
    self.SetTitle(title)
  end

  # remove x axis labels and title
  def delete_x_axis
    self.GetXaxis.SetLabelOffset(999)
    self.GetXaxis.SetTitleOffset(999)
  end

  alias delete_xaxis delete_x_axis
  alias remove_x_axis delete_x_axis
  alias remove_xaxis delete_x_axis
  alias no_x delete_x_axis
end

module Root::PlotManipulator
  private

  def set_font_if_nil
    if @font_style.nil?
      @font_style = 43
      @fontSize = 12
    end
  end

  public

  def text_font(font_style)
    @font_style = font_style
  end

  def text_size(font_size)
    @fontSize = font_size
  end

  def text(str, x = 0.5, y = 0.5)
    set_font_if_nil
    t = Root::TText.new
    t.SetTextFont(@font_style.to_i)
    t.SetTextSize(@fontSize.to_i)
    t.DrawTextNDC(x, y, str)
  end

  def text_graph_coordinate(str, x = 0.5, y = 0.5)
    set_font_if_nil
    t = Root::TText.new
    t.SetTextFont(@font_style.to_i)
    t.SetTextSize(@fontSize.to_i)
    t.DrawText(x, y, str)
  end
end

module Root::PadManipulator
  # log
  def log(axes = "xyz")
    axes.downcase!
    logx if axes.include?("x")
    logy if axes.include?("y")
    logz if axes.include?("z")
  end

  def logx(mode = 1)
    self.SetLogx(mode)
  end

  def logy(mode = 1)
    self.SetLogy(mode)
  end

  def logz(mode = 1)
    self.SetLogz(mode)
  end

  def logxy(mode = 1)
    self.SetLogx(mode)
    self.SetLogy(mode)
  end

  def logxyz(mode = 1)
    self.SetLogx(mode)
    self.SetLogy(mode)
    self.SetLogz(mode)
  end

  alias log_x logx
  alias log_y logy
  alias log_z logz
  alias log_xy logxy

  def log_off
    logxyz(0)
  end

  alias logoff log_off

  def logx_off
    logx(0)
  end

  alias logxoff logx_off

  def logy_off
    logy(0)
  end

  alias logyoff logy_off

  def logz_off
    logz(0)
  end

  alias logzoff logz_off

  # grid
  def grid(axes = "xy")
    axes.downcase!
    gridx if axes.include?("x")
    gridy if axes.include?("y")
  end

  def gridy(mode = 1)
    self.SetGridy(mode)
  end

  def gridx(mode = 1)
    self.SetGridx(mode)
  end

  def gridxy(mode = 1)
    self.SetGridx(mode)
    self.SetGridy(mode)
  end

  def grid_off
    gridxy(0)
  end

  alias gridoff grid_off

  def gridx_off
    gridx(0)
  end

  alias gridxoff gridx_off

  def gridy_off
    gridy(0)
  end

  alias gridyoff gridy_off

  # multi plots
  def divide(nx, ny)
    self.Divide(nx, ny)
  end

  # multi plot (typical setting for spectrum-ratio or spectrum-deviation plot)
  def divide_top_bottom(top_fraction = 0.7)
    if top_fraction >= 1
      raise "Error: Invalid top_fraction for TCanvas.divide_top_bottom()."
    end
    @@Minification = 0.95
    cd(0)
    self.Divide(1, 2)
    self.GetPad(1).SetPad(0, (1 - top_fraction) * @@Minification,
                          1 * @@Minification, 1 * @@Minification)
    self.GetPad(2).SetPad(0, 0,
                          1 * @@Minification, (1 - top_fraction) * @@Minification)
    self.GetPad(1).SetFillStyle(0)
    self.GetPad(2).SetFillStyle(0)
    self.GetPad(1).SetMargin(0.15, 0.03, 0, 0.00)
    self.GetPad(2).SetMargin(0.15, 0.03, 0.26, 0.04)
  end

  def margin(top = 0.1, right = 0.05, bottom = 0.1, left = 0.1)
    Root.gPad.SetMargin(left, right, bottom, top)
  end

  def margin_top(top = 0.05)
    Root.gPad.SetTopMargin(top)
  end

  def margin_right(right = 0.05)
    Root.gPad.SetRightMargin(right)
  end

  def margin_bottom(bottom = 0.05)
    Root.gPad.SetBottomMargin(bottom)
  end

  def margin_left(left = 0.05)
    Root.gPad.SetLeftMargin(left)
  end

  def get_margin
    [get_margin_top, get_margin_right, get_margin_bottom, get_margin_left]
  end

  def get_margin_top
    Root.gPad.GetTopMargin
  end

  def get_margin_right
    Root.gPad.GetRightMargin
  end

  def get_margin_bottom
    Root.gPad.GetBottomMargin
  end

  def get_margin_left
    Root.gPad.GetLeftMargin
  end

  def transparent
    Root.gPad.SetFillStyle(0)
  end

  # move current panel to n-th panel
  def move_to(n)
    cd(n)
  end
end

module Root
  class TVirtualPad
    include PlotManipulator
    include PadManipulator

    def set(&block)
      Root.gStyle.SetTitleAlign(12)
      instance_eval(&block)
    end

    alias style set
  end

  class TCanvas
    include PlotManipulator
    include PadManipulator

    def set(&block)
      Root.gStyle.SetTitleAlign(12)
      instance_eval(&block)
    end

    alias style set

    # save to file
    def save_as(file_name)
      self.SaveAs(file_name)
    end

    alias saveas save_as
    alias save save_as
  end

  class TGraph
    def get_point(i)
      [getX(i), getY(i)]
    end

    def [](i)
      [getX(i), getY(i)]
    end
  end

  class TLegend
    def add(array_of_objects, option = "p")
      if not array_of_objects.instance_of?(Array)
        array_of_objects = [array_of_objects]
      end
      array_of_objects.each() { |e|
        title = ""
        begin
          title = e.GetTitle()
        rescue
          title = ""
        end
        if title == ""
          begin
            title = e.GetName()
          rescue
            puts "ruby-root: TLegend::add could not retrieve title from object"
            title = "No title"
          end
        end
        # If TGraph, set option="p"
        if e.instance_of?(TGraph)
          option = "p"
        end
        # If TH1x, add "lp" to option
        if e.instance_of?(TH1B) or e.instance_of?(TH1S) or e.instance_of?(TH1I) or e.instance_of?(TH1F) or e.instance_of?(TH1D)
          option += "lp"
        end
        self.AddEntry(e, title, option)
      }
    end
  end
end

module Root::HistogramManipulationInterface
  def clone(new_name)
    xaxis = self.GetXaxis()
    h = TH1D.create(new_name, new_name,
                    xaxis.GetNbins(), xaxis.GetXmin(), xaxis.GetXmax())
    for i in 0..(self.GetXaxis.GetNbins() + 1)
      a = self.GetBinContent(i)
      h.SetBinContent(i, a)
    end
    h
  end

  def dump_hist_bin_error(divider)
    d = divider
    str = <<EOS
     self.nbins = #{nbins} xmin = #{xmin} xmax = #{xmax}
  divider.nbins = #{d.nbins} xmin = #{d.xmin} xmax = #{d.xmax}
EOS
    str
  end

  def divide_by(hist, _new_name = "")
    if self.GetXaxis.GetNbins != hist.GetXaxis().GetNbins
      lines = [
        "Error: divide_by(): histograms have different X axis bin number,",
        " and therefore bin-by-bin division cannot be executed.",
        dump_hist_bin_error(hist).to_s,
      ]
      raise lines.join
    end
    for i in 0..(self.GetXaxis.GetNbins())
      if self.GetXaxis.GetBinCenter(i) != hist.GetXaxis().GetBinCenter(i)
        lines = [
          "Error: divide_by(): histograms have different X axis binning",
          " (at bin #{i}, binters are #{self.GetXaxis.GetBinCenter(i)}!=",
          "#{hist.GetXaxis().GetBinCenter(i)}, and therefore bin-by-bin",
          "division cannot be executed. #{dump_hist_bin_error(hist)}",
        ]
        raise lines.join
      end
      a = self.GetBinContent(i)
      b = hist.GetBinContent(i)
      self.SetBinContent(i, a / b) if b != 0
    end
    # return h
  end

  def nbins(axis = "x")
    axis.downcase!
    case axis
    when "x" then return self.GetXaxis.GetNbins
    when "y" then return self.GetYaxis.GetNbins
    when "z" then return self.GetZaxis.GetNbins
    else
      raise "Error: nbins(axis): axis should be one of x/y/z."
    end
  end

  def xmin
    self.GetXaxis.GetXmin
  end

  def xmax
    self.GetXaxis.GetXmax
  end
end

class TH1D
  include Root::HistogramManipulationInterface
end

#---------------------------------------------
# Data loader
#---------------------------------------------
def load_data_as_graph(file_name, xycolumns = [0, 1], delimitter = " ")
  puts "Creating graph from #{file_name} (columns #{xycolumns.join(" and ")})"
  graph_name = "graph_" + File.basename(file_name, ".*")
  g = Root::TGraph.create([], [])
  g.SetName(graph_name)

  x_column_index = xycolumns[0]
  y_column_index = xycolumns[1]

  open(file_name).each do |line|
    array = line.split(delimitter)
    x = array[x_column_index].to_f
    y = array[y_column_index].to_f
    g.SetPoint(g.GetN, x, y)
  end
  puts "#{g.GetN} data points have been added to graph named " #{graph_name}""
  g
end

#---------------------------------------------
# Mix in
#---------------------------------------------
class Root::TH1D
  include Root::Plottable
end

module Root
  class TGraph
    include Root::Plottable
  end

  class TH1F
    include Root::Plottable
  end

  class TH1I
    include Root::Plottable
  end

  class TH1S
    include Root::Plottable
  end

  class TH1B
    include Root::Plottable
  end

  class TH2D
    include Root::Plottable

    def plot(option = "colz")
      margin_right(0.15)
      Draw(option)
    end
  end

  class TH2F
    include Root::Plottable

    def plot(option = "colz")
      Root.gPad.margin_right(0.15)
      Draw(option)
    end
  end

  class TH2I
    include Root::Plottable

    def plot(option = "colz")
      Root.gPad.margin_right(0.15)
      Draw(option)
    end
  end

  class TH2S
    include Root::Plottable

    def plot(option = "colz")
      Root.gPad.margin_right(0.15)
      Draw(option)
    end
  end

  class TH2B
    include Root::Plottable

    def plot(option = "colz")
      Root.gPad.margin_right(0.15)
      Draw(option)
    end
  end

  class TNamed
    def name(new_name)
      self.SetName(new_name)
    end
  end
end
