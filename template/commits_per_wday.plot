require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'commits_per_wday.png')
    plot.nokey
    plot.xrange '[0.5:7.5]'
    plot.xtics '1'
    plot.grid 'y'
    plot.ylabel 'Commits'
    plot.yrange '[0:]'

    x = Array.new
    labels = Array.new
    y = Array.new

    stats.wday_stats.days.sort.each do |day, stats|
      day = (day + 1) % 7
      names = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ]
      x << day + 1
      labels << names[day]
      y << stats.commits
    end

    plot.data << Gnuplot::DataSet.new([x, labels, y]) do |ds|
      ds.using = '1:3:(0.5):xtic(2)'
      ds.with = 'boxes fs solid'
      ds.notitle
    end
  end
end
