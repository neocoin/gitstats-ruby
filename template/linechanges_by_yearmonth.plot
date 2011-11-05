defplot do |plotter|
  plotter.add_steps do |x, l, y|
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      x << yearmonth.to_i
      l << yearmonth.to_s
      y << stats.lines_added
    end
  end

  plotter.add_steps do |x, l, y|
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      x << yearmonth.to_i
      l << yearmonth.to_s
      y << stats.lines_deleted
    end
  end
end
