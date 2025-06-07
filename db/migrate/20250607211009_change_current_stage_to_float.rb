class ChangeCurrentStageToFloat < ActiveRecord::Migration[7.1]
  def up
    change_column :game_sessions, :current_stage, :float, default: 0.0
  end

  def down
    change_column :game_sessions, :current_stage, :decimal, precision: 3, scale: 1, default: 0.0
  end
end
