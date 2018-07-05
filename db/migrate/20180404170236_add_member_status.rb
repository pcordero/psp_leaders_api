class AddMemberStatus < ActiveRecord::Migration[5.1]
  def up
    add_column :leaders, :member_status, :string
  end

  def down
    remove_column :leaders, :member_status
  end
end
