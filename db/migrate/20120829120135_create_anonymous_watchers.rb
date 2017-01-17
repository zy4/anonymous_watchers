class CreateAnonymousWatchers < ActiveRecord::Migration
  def self.up
    create_table :anonymous_watchers, :force => true do |t|
      t.string  :watchable_type, :default => "", :null => false
      t.integer :watchable_id,   :default => 0,  :null => false
      t.string  :mail
    end

    add_index :anonymous_watchers, [:mail]
    add_index :anonymous_watchers, [:watchable_id, :watchable_type]

    if Watcher.column_names.include? "mail"
      Watcher.connection.execute("INSERT INTO anonymous_watchers (watchable_type, watchable_id, mail) SELECT watchable_type, watchable_id, mail FROM watchers WHERE mail IS NOT NULL")
      Watcher.delete_all("mail IS NOT NULL")
      remove_column :watchers, :mail
    end
  end

  def self.down
    drop_table :anonymous_watchers
  end
end
