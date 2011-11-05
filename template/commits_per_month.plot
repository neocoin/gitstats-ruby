require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'commits_per_month.png')
    plot.nokey
    plot.xrange '[0.5:12.5]'
    plot.xtics '1'
    plot.grid 'y'
    plot.ylabel 'Commits'
    plot.yrange '[0:]'

    x = Array.new
    label = Array.new
    y = Array.new

    names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ]

    for month in 1..12
      s = stats.month_stats[month]
      x << month
      label << names[month - 1]
      y << (s.nil? ? 0 : s.commits)
    end

    plot.data << Gnuplot::DataSet.new([x, label, y]) do |ds|
      ds.using = '1:3:(0.5):xtic(2)'
      ds.with = 'boxes fs solid'
      ds.notitle
    end
  end
end
