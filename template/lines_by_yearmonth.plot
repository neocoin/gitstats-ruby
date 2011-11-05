defplot do |plotter|
  plotter.add_steps do |x, l, y|
    lines = 0
    stats.yearmonth_stats.each_sorted do |yearmonth, stats|
      lines += stats.lines
      x << yearmonth.to_i
      l << yearmonth.to_s
      y << lines
    end
  end
end
