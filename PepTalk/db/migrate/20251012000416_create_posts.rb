class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.string :owner
      t.string :recipient
      t.text :shareLink
      t.integer :status

      t.timestamps
    end
  end
end
