defplot do |plotter|
  plotter.plot.xrange '[-0.5:23.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes(:setrange => false, :limitlabels => false) do |x, l, y|
    for hour in 0..23
      s = stats.hour_stats[hour]
      x << hour
      l << hour
      y << (s.nil? ? 0 : s.commits)
    end
  end
end
