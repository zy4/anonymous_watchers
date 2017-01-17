class AddAnonymousTokenToAnonymousWatchers < ActiveRecord::Migration
  def self.up
    add_column :anonymous_watchers, :anonymous_token, :string, :null => false, :default => ""
  end
  def self.down
    remove_column :anonymous_watchers, :anonymous_token
  end
end
