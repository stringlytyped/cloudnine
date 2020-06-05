class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :open_weather_id
      t.integer :utc_offset
      t.timestamp :sunrise
      t.timestamp :sunset
      t.string :condition_id
      t.string :condition_description
      t.string :condition_icon
      t.float :temperature
      t.float :feels_like
      t.float :humidity
      t.float :wind_speed
      t.float :cloud_cover
      t.float :rainfall_1h
      t.float :rainfall_3h
      t.float :snowfall_1h
      t.float :snowfall_3h

      t.timestamps
    end

    change_table :users do |t|
      t.references :location
    end

    add_index :locations, :open_weather_id, unique: true
  end
end
