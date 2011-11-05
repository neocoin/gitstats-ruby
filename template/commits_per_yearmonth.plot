require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'commits_per_yearmonth.png')
    plot.nokey
    plot.xtics 'rotate'
    plot.grid 'y'
    plot.ylabel 'Commits'
    plot.yrange '[0:]'

    x = Array.new
    label = Array.new
    y = Array.new

    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      x << yearmonth.to_i
      label << yearmonth.to_s
      y << stats.commits
    end
    plot.xrange "[\"#{x.first - 1}\":\"#{x.last + 1}\"]"

    plot.data << Gnuplot::DataSet.new([x, label, y]) do |ds|
      ds.using = '1:3:(0.5):xtic(2)'
      ds.with = 'boxes fs solid'
      ds.notitle
    end
  end
end
