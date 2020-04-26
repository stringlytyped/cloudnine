class MoodRating < ApplicationRecord
  belongs_to :user
  validates_inclusion_of :value, :in => [0, 0.5, 1]
end
