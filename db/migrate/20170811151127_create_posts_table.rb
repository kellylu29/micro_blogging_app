class CreatePostsTable < ActiveRecord::Migration[5.1]
  def change
  	create_table :posts do |t|
  		t.string :content
  		t.string :username
      t.string :title
      t.string :user_id
  	end
  end
end
