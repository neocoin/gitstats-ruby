defplot do |plotter|
  plotter.plot.xrange '[0.5:12.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'
  plotter.plot.yrange '[0:]'

  plotter.add_boxes(:setrange => false, :limitlabels => false) do |x, l, y|
    for month in 1..12
      s = stats.month_stats[month]
      x << month
      l << monthname(month)
      y << (s.nil? ? 0 : s.commits)
    end
  end
end
