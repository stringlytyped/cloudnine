class CreateMoodRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :mood_ratings do |t|
      t.references :user
      t.float :value
      t.timestamps
    end
  end
end
