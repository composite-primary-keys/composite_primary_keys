ActiveRecord::ConnectionAdapters::ColumnDefinition.send(:alias_method, :to_s_without_composite_keys, :to_s)

ActiveRecord::ConnectionAdapters::ColumnDefinition.class_eval <<-'EOF'
  def to_s
    if name.is_a? Array
      "PRIMARY KEY (#{name.join(',')})"
    else
      to_s_without_composite_keys
    end
  end
EOF


