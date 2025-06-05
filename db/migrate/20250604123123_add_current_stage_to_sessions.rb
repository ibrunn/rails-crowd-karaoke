class AddCurrentStageToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :current_stage, :decimal, precision: 3, scale: 1, default: 0
    add_column :sessions, :stage_started_at, :datetime
    add_column :sessions, :stage_data, :json, default: {}

    add_index :sessions, :current_stage
    add_index :sessions, :stage_started_at
  end
end
