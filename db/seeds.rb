category_tags = %w[Movies Music TV Sports Gaming Tech]

category_tags.each do |name|
  Tag.find_or_create_by!(name: name, tag_type: 'category')
end
