module Admin::ActivitiesHelper
  # This function may be the butt-ugliest piece of software ever written in Winston Design. Go Joel!
  def activity_date_for_period(period)
    s = period.first.day.to_s
    if period.first.year != period.last.year
      s += ' ' + period.first.strftime("%b") + " #{period.first.year} till "
    elsif period.first.month != period.last.month
      s += ' ' + period.first.strftime("%b") + ' till '
    else
      s += '-'
    end
    s += "#{period.last.day} #{period.last.strftime("%b")} #{period.last.year}"
    s
  end
  
  def activity_table(first_period, second_period, options = {}, &block)
    block_to_partial 'admin/activities/activity_table', {:first_period => first_period, :second_period => second_period, :export_links => true}.merge(options), &block
  end
  
end
