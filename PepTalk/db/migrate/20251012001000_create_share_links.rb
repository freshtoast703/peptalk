class CreateShareLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :share_links do |t|
      t.string :token, null: false
      t.references :post, null: false, foreign_key: true, index: true
      t.references :user, null: true, foreign_key: true
      t.string :permissions, null: false, default: 'read'
      t.datetime :expires_at
      t.datetime :revoked_at
      t.integer :access_count, null: false, default: 0
      t.datetime :last_accessed_at

      t.timestamps
    end

    add_index :share_links, :token, unique: true
    add_index :share_links, :expires_at

    reversible do |dir|
      dir.up do
        # Create a partial index for active tokens only on PostgreSQL. SQLite
        # doesn't support the now() function or partial indexes with functions.
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
          execute <<-SQL.squish
            CREATE INDEX index_share_links_on_token_active
            ON share_links (token)
            WHERE revoked_at IS NULL AND (expires_at IS NULL OR expires_at > now());
          SQL
        end
      end
      dir.down do
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
          execute "DROP INDEX IF EXISTS index_share_links_on_token_active;"
        end
      end
    end
  end
end
