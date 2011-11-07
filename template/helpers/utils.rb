module UtilsHelper
  def filesize(i)
    case
    when i > 1000000000
      '%dG' % (i / 1000000000).to_i
    when i > 1000000
      '%dM' % (i / 1000000).to_i
    when i > 1000
      '%dk' % (i / 1000).to_i
    else
      i.to_s
    end
  end
end

self.extend UtilsHelper
