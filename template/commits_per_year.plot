defplot do |plotter|
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes do |x, l, y|
    stats.year_stats.each_sorted do |year, stats|
      x << year
      l << year
      y << stats.commits
    end
  end
end
