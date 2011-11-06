class FileTypeFileStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(file)
    type = File.extname(file[:name])
    @hash[type] ||= FileStats.new
    @hash[type].update(file)
  end
end

