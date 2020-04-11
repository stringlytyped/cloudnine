class AddUserToMoods < ActiveRecord::Migration[6.0]
  def change
    add_column :moods, :user_id, :integer
  end
end
