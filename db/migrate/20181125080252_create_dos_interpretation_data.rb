class CreateDosInterpretationData < ActiveRecord::Migration[5.2]
  def change
    create_table :dos_interpretation_data do |t|
      t.belongs_to  :friendly_resource
      t.float       :baseline
      t.float       :trend
      t.float       :seasonal_trend
      t.float       :weighted_average_absolute_deviation
      t.boolean     :aberrant_behavior
      t.float       :actual_value
      t.timestamps
    end
  end
end
