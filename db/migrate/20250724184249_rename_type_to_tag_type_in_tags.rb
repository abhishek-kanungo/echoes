class RenameTypeToTagTypeInTags < ActiveRecord::Migration[8.0]
  def change
    rename_column :tags, :type, :tag_type
  end
end