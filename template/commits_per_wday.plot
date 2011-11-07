defplot do |plotter|
  plotter.plot.xrange '[0.5:7.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes(:setrange => false, :limitlabels => false) do |x, l, y|
    for i in 0..6
      s = stats.wday_stats[i]
      day = (i + 6) % 7
      x << day + 1
      l << weekday(day)
      y << (s.nil? ? 0 : s.commits)
    end
  end
end
