class CreateProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :profiles do |t|
      t.string :cv
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
