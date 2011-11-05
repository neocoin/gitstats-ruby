require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'linechanges_by_yearmonth.png')
    plot.nokey
    plot.xdata 'time'
    plot.timefmt '"%Y-%m"'
    plot.format 'x "%Y-%m"'
    plot.grid 'y'
    plot.xtics 'rotate'
    plot.ytics 'autofreq'
    plot.yrange '[0:]'

    x = Array.new
    y1 = Array.new
    y2 = Array.new

    stats.yearmonth_stats.sort.each do |yearmonth, stats|
      x << yearmonth
      y1 << stats.lines_added
      y2 << stats.lines_deleted
    end

    plot.data << Gnuplot::DataSet.new([x, y1]) do |ds|
      ds.using = '1:2'
      ds.with = 'steps'
      ds.notitle
    end

    plot.data << Gnuplot::DataSet.new([x, y2]) do |ds|
      ds.using = '1:2'
      ds.with = 'steps'
      ds.notitle
    end
  end
end
