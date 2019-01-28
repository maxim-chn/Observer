##
# Specifies creation of table icmp_flood_reports.
class CreateIcmpFloodReports < ActiveRecord::Migration[5.2]
  def change
    create_table :dos_icmp_interpretations do |t|
      t.belongs_to :friendly_resource
      t.boolean :aberrant_behavior
      t.float :actual_value
      t.float :baseline
      t.float :confidence_band_upper_value
      t.float :estimated_value
      t.float :linear_trend
      t.integer :seasonal_index
      t.float :seasonal_trend
      t.string :report_type
      t.float :weighted_avg_abs_deviation 
      t.float :time_spent
      t.timestamps
    end
  end
end
