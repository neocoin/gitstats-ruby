require "gnuplot"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal 'png transparent size 640,240'
    plot.size '1.0,1.0'
    plot.output File.join(outdir, 'lines_by_yearmonth.png')
    plot.nokey
    plot.grid 'y'
    plot.xtics 'rotate'
    plot.ytics 'autofreq'
    plot.yrange '[0:]'

    x = Array.new
    label = Array.new
    y = Array.new

    lines = 0
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      lines += stats.lines
      x << yearmonth.to_i
      label << yearmonth.to_s
      y << lines
    end

    plot.xrange "[#{x.first - 1}:#{x.last + 1}]"

    x.insert(0, x.first - 1);
    label.insert(0, YearMonth.new(x.first).to_s)
    y.insert(0, 0)

    plot.data << Gnuplot::DataSet.new([x, label, y]) do |ds|
      ds.using = '1:3:xtic(2)'
      ds.with = 'steps'
      ds.notitle
    end
  end
end
