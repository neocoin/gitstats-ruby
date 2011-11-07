module ConfigHelper
  def author_count
    100
  end

  def top_author_count
    20
  end
end

self.extend ConfigHelper

