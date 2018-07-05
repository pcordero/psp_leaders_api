class CreateSourceOffsets < ActiveRecord::Migration[5.1]
  def change
    create_table :source_offsets do |t|
      t.timestamps
      t.date :date_created_at
      t.string :state
      t.string :scope1
      t.string :scope2
      t.integer :offset
    end
    add_index :source_offsets, [:date_created_at, :state, :scope1, :scope2], :name => "dca__state__scope1__scope2", :unique => true
  end
end