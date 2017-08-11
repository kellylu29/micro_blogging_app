class CreateUsersPosts < ActiveRecord::Migration[5.1]
  def change
  	create_table :users_posts do |t|
		t.integer :user_id
		t.integer :post_id
	end
  end
end
