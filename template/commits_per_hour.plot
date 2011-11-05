defplot do |plotter|
  plotter.plot.xrange '[-0.5:23.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes(:setrange => false, :limitlabels => false) do |x, l, y|
    stats.hour_stats.sort.each do |hour, stats|
      x << hour
      l << hour
      y << stats.commits
    end
  end
end
