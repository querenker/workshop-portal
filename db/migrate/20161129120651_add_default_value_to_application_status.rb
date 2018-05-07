class AddDefaultValueToApplicationStatus < ActiveRecord::Migration[4.2]
  def change
    change_column :application_letters, :status, 'integer USING CAST(status AS integer)', default: 2
    change_column_null :application_letters, :status, false, 2
  end
end
