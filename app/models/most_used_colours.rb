require 'open3'

class MostUsedColours
  class ImageMagickUnExpectedOutputError < StandardError; end

  attr_reader :file

  def initialize(file:)
    @file = file
  end

  def call(limit: 5)
    colours = command
    .lines
    .reject     { |c| transparent?(c) }
    .map        { |l| Colour.by_im_line(l) }
    .select     { |c| c.solid? }
    .reject     { |c| c.irrelevant? }
    .reject     { |c| c.white_or_similar? }
    .sort

    remove_similar_colours(colours)
    .take   limit
  end

  class Colour
    JND = 3.8
    WHITE = Color::RGB.by_hex('ffffff').to_lab

    def self.by_im_line(line)
      new(line)
    end

    def initialize(line)
      @line = line
    end

    def rgb
      @rgb ||= @line.match(/#\h{6}/).to_s
    end

    def srgb
      @srgb ||= @line.match(/srgba\((?<R>\d+),(?<G>\d+),(?<B>\d+)(,(?<A>\d+(\.?\d+)?))?\)?/)
    end

    def pixels
      @pixels ||= @line.match(/\d+:/).to_s.gsub(':', '').to_i
    end

    def lab
      @lab ||= Color::RGB.by_hex(rgb.gsub('#', '')).to_lab
    end

    def white_or_similar?
      Color::RGB.new.delta_e94(WHITE, lab) <= JND
    end

    def solid?
      alpha = (srgb || {A:1})[:A]
      alpha.to_f == 1
    end

    def similar?(colour)
      Color::RGB.new.delta_e94(lab, colour.lab) <= JND
    end

    def <=>(other)
      other.pixels <=> pixels
    end

    def irrelevant?
      pixels < 100
    end
  end

  private

  def remove_similar_colours(colours)
    i = 0
    while !colours[i].nil? && !colours[i+1].nil?
      colours = colours[0..i] +  colours[(i+1)..-1].reject {|c| colours[i].similar?(c) }
      i += 1
    end

    colours
  end

  def transparent?(colour)
    colour.match(/none$/)
  end

  def command
    stdout, stderr, status = Open3.capture3({"IMAGE_PATH" => file}, "convert ${IMAGE_PATH} +dither -format \"%c\" histogram:info:")
    raise ImageMagickUnExpectedOutputError.new("Status #{status} | stderr: #{stderr}") unless status.success?
    stdout
  end
end
