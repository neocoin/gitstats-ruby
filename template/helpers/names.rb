module NamesHelper
  def label(name)
    @names ||= {
      :repos => 'Repositories',
      :general => 'Stats',
      :hour_of_day => 'Hour of day',
      :day_of_week => 'Day of week',
      :hour_of_week => 'Hour of week',
      :commits_per_month => 'Commits per month',
      :commits_per_year => 'Commits per year',
      :commits_per_yearmonth => 'Commits per year and month',
      :authors => "Top #{author_count} authors",
      :top_authors_of_year => "Top #{top_author_count} authors of year",
      :top_authors_of_yearmonth => "Top #{top_author_count} authors of year and month",
      :files_by_yearmonth => 'Files by year and month',
      :filechanges_by_yearmonth => 'Filechanges by year and month',
      :lines_by_yearmonth => 'Lines by year and month',
      :linechanges_by_yearmonth => 'Linechanges by year and month',
      :filetypes => 'Filetypes',
      :lastweeks => 'Last years weeks',
      :fileschart => 'Fileschart',
      :lineschart => 'Lineschart',
      :commitchart => 'Commitchart',
    }

    @names[name].nil? ? name.to_s : @names[name]
  end

  def weekday(wday)
    case wday
    when 0
      'Mon'
    when 1
      'Tue'
    when 2
      'Wed'
    when 3
      'Thu'
    when 4
      'Fri'
    when 5
      'Sat'
    when 6
      'Sun'
    end
  end

  def monthname(month)
    case month
    when 1
      'Jan'
    when 2
      'Feb'
    when 3
      'Mar'
    when 4
      'Apr'
    when 5
      'May'
    when 6
      'Jun'
    when 7
      'Jul'
    when 8
      'Aug'
    when 9
      'Sep'
    when 10
      'Oct'
    when 11
      'Nov'
    when 12
      'Dec'
    end
  end
end

self.extend NamesHelper

