defplot do |plotter|
  plotter.plot.xrange '[52.5:0.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'

  plotter.add_boxes(:setrange => false) do |x, l, y|
    51.downto 0 do |i|
      s = stats.lastweeks_stats[i]
      x << i + 1
      l << i + 1
      y << (s.nil? ? 0 : s.commits)
    end
  end
end
