# frozen_string_literal: true

##
# Specifies the creation of the sql_injection_reports table.
class CreateSqlInjectionReports < ActiveRecord::Migration[5.2]
  def change
    create_table :sql_injection_reports do |t|
      t.belongs_to :friendly_resource
      t.text :reason

      t.timestamps
    end
  end
end
