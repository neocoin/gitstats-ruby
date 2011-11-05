defplot do |plotter|
  plotter.add_steps do |x, l, y|
    files = 0
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      files += stats.files
      x << yearmonth.to_i
      l << yearmonth.to_s
      y << files
    end
  end
end
