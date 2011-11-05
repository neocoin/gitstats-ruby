defplot do |plotter|
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes do |x, l, y|
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      x << yearmonth.to_i
      l << yearmonth.to_s
      y << stats.commits
    end
  end
end
