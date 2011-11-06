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
      :authors => 'Authors',
      :top_authors_of_year => 'Top authors of year',
      :top_authors_of_yearmonth => 'Top authors of year and month',
      :files_by_yearmonth => 'Files by year and month',
      :filechanges_by_yearmonth => 'Filechanges by year and month',
      :lines_by_yearmonth => 'Lines by year and month',
      :linechanges_by_yearmonth => 'Linechanges by year and month',
      :filetypes => 'Filetypes',
    }

    @names[name].nil? ? name.to_s : @names[name]
  end
end

self.extend NamesHelper

