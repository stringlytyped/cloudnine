class Mood < ApplicationRecord
    belongs_to :user
    validates_inclusion_of :rating, :in => [0, 0.5, 1], :allow_nil => true
end
