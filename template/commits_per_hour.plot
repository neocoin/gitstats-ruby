require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'commits_per_hour.png')
    plot.nokey
    plot.xrange '[0.5:24.5]'
    plot.xtics '1'
    plot.grid 'y'
    plot.ylabel 'Commits'
    plot.yrange '[0:]'

    x = Array.new
    y = Array.new

    stats.hour_stats.sort.each do |hour, stats|
      x << hour
      y << stats.commits
    end

    plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
      ds.using = '1:2:(0.5)'
      ds.with = 'boxes fs solid'
      ds.notitle
    end
  end
end
