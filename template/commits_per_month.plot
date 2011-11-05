defplot do |plotter|
  plotter.plot.xrange '[0.5:12.5]'
  plotter.plot.xtics '1'
  plotter.plot.ylabel 'Commits'
  plotter.plot.yrange '[0:]'

  plotter.add_boxes(:setrange => false, :limitlabels => false) do |x, l, y|
    names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ]

    for month in 1..12
      s = stats.month_stats[month]
      x << month
      l << names[month - 1]
      y << (s.nil? ? 0 : s.commits)
    end
  end
end
