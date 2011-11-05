require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'files_by_yearmonth.png')
    plot.nokey
    plot.xdata 'time'
    plot.timefmt '"%Y-%m"'
    plot.format 'x "%Y-%m"'
    plot.grid 'y'
    plot.xtics 'rotate'
    plot.ytics 'autofreq'
    plot.yrange '[0:]'

    x = Array.new
    y = Array.new

    files = 0
    stats.yearmonth_stats.sort.each do |yearmonth, stats|
      files += stats.files
      x << yearmonth
      y << files
    end

    plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
      ds.using = '1:2'
      ds.with = 'steps'
      ds.notitle
    end
  end
end
