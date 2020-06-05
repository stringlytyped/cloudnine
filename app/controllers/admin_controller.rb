class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_admins!
  
  def index
    @mood_ratings = MoodRating
    @avg_daily_change = avg_daily_change_in_mood
  end

  private

  def avg_daily_change_in_mood(period=30.days)
    users = User.where("updated_at > ?", period.ago)

    # [{Fri 05 Jun 2020 => 1.0, Thu 04 Jun 2020 => 0.5}, {Fri 05 Jun 2020 => 0}]
    daily_deltas_by_user = users.map do |user|
      utc_offset = user.location ? user.location.utc_offset : 0
      # #<ActiveRecord::Relation [#<MoodRating id:1 ...>, #<MoodRating id:2 ...>, ...]>
      moods = MoodRating.where("user_id = ? AND updated_at > ?", user.id, period.ago)

      # {Fri 05 Jun 2020 => [#<MoodRating id:1 ...>, #<MoodRating id:2 ...>, ...],
      #  Thu 04 Jun 2020 => [#<MoodRating id:5 ...>, #<MoodRating id:6 ...>, ...]}
      moods_by_day =
        moods.group_by do |mood|
          local_time = mood.created_at.getlocal(utc_offset)
          # Since many people stay up past midnight, 3 AM is used as the cut-off to seperate one day from the next
          local_time.hour > 3 ? local_time.to_date : local_time.to_date.prev_day
        end
      
      # Remove any days that didn't have a change in mood
      moods_by_day.reject { |date, moods| moods.length <= 1 }

      # [[Fri 05 Jun 2020, 1.0], [Thu 04 Jun 2020, 0.5]]
      daily_deltas =
        moods_by_day.map do |date, moods|
          moods = moods.sort { |a, b| a.id <=> b.id }
          [date, moods.last.value - moods.first.value]
        end

      # {Fri 05 Jun 2020 => 1.0, Thu 04 Jun 2020 => 0.5}
      daily_deltas.to_h
    end

    # {Fri 05 Jun 2020 => [1.0, 0], Thu 04 Jun 2020 => 0.5}
    deltas_by_date = 
      daily_deltas_by_user.reduce do |acc, daily_deltas|
        acc.merge(daily_deltas) { |key, a, b| [a, b].flatten }
      end

    # [[Fri 05 Jun 2020, 0.5], [Thu 04 Jun 2020, 0.5]]
    avg_delta_by_date =
      deltas_by_date.map do |date, deltas|
        if deltas.kind_of?(Array)
          [date, deltas.sum / deltas.length]
        else
          [date, deltas]
        end
      end
    
    # {Fri 05 Jun 2020 => 0.5, Thu 04 Jun 2020 => 0.5}
    avg_delta_by_date.to_h
  end
end