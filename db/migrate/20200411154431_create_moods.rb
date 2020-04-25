class CreateMoods < ActiveRecord::Migration[6.0]
  def change
    create_table :moods do |t|
      t.string :username
      t.float :rating
      t.datetime :when

      t.timestamps
    end
  end
end
