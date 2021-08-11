module ActiveRecord
  module Associations
    class JoinDependency

      class JoinAssociation < JoinPart # :nodoc:
        private
          def append_constraints(join, constraints)
            if join.is_a?(Arel::Nodes::StringJoin)
              join_string = Arel::Nodes::And.new(constraints.unshift join.left)
              join.left = Arel.sql(base_klass.connection.visitor.compile(join_string))
            else
              right = join.right
              # CPK
              if right.expr.children.empty?
                right.expr = Arel::Nodes::And.new(constraints)
              else
                right.expr = Arel::Nodes::And.new(constraints.unshift right.expr)
              end
            end
          end
      end

      class Aliases # :nodoc:
        def column_alias(node, column)
          # CPK
          #@alias_cache[node][column]
          if column.kind_of?(Array)
            column.map do |a_column|
              @alias_cache[node][a_column]
            end
          else
            @alias_cache[node][column]
          end
        end
      end

      def instantiate(result_set, strict_loading_value, &block)
        primary_key = aliases.column_alias(join_root, join_root.primary_key)

        seen = Hash.new { |i, parent|
          i[parent] = Hash.new { |j, child_class|
            j[child_class] = {}
          }
        }.compare_by_identity

        model_cache = Hash.new { |h, klass| h[klass] = {} }
        parents = model_cache[join_root]

        column_aliases = aliases.column_aliases(join_root)
        column_names = []

        result_set.columns.each do |name|
          column_names << name unless /\At\d+_r\d+\z/.match?(name)
        end

        if column_names.empty?
          column_types = {}
        else
          column_types = result_set.column_types
          unless column_types.empty?
            attribute_types = join_root.attribute_types
            column_types = column_types.slice(*column_names).delete_if { |k, _| attribute_types.key?(k) }
          end
          column_aliases += column_names.map! { |name| Aliases::Column.new(name, name) }
        end

        message_bus = ActiveSupport::Notifications.instrumenter

        payload = {
          record_count: result_set.length,
          class_name: join_root.base_klass.name
        }

        message_bus.instrument("instantiation.active_record", payload) do
          result_set.each { |row_hash|
            # CPK
            # parent_key = primary_key ? row_hash[primary_key] : row_hash
            parent_key = if primary_key.kind_of?(Array)
                           primary_key.map {|key| row_hash[key]}
                         else
                           primary_key ? row_hash[primary_key] : row_hash
                         end

            parent = parents[parent_key] ||= join_root.instantiate(row_hash, column_aliases, column_types, &block)
            construct(parent, join_root, row_hash, seen, model_cache, strict_loading_value)
          }
        end

        parents.values
      end

      def construct(ar_parent, parent, row, seen, model_cache, strict_loading_value)
        return if ar_parent.nil?

        parent.children.each do |node|
          if node.reflection.collection?
            other = ar_parent.association(node.reflection.name)
            other.loaded!
          elsif ar_parent.association_cached?(node.reflection.name)
            model = ar_parent.association(node.reflection.name).target
            construct(model, node, row, seen, model_cache, strict_loading_value)
            next
          end

          key = aliases.column_alias(node, node.primary_key)
          # CPK
          if key.is_a?(Array)
            id = Array(key).map do |column_alias|
              row[column_alias]
            end
            # At least the first value in the key has to be set.  Should we require all values to be set?
            id = nil if id.first.nil?
          else # original
            id = row[key]
          end

          if id.nil?
            nil_association = ar_parent.association(node.reflection.name)
            nil_association.loaded!
            next
          end

          model = seen[ar_parent][node][id]

          if model
            construct(model, node, row, seen, model_cache, strict_loading_value)
          else
            model = construct_model(ar_parent, node, row, model_cache, id, strict_loading_value)

            seen[ar_parent][node][id] = model
            construct(model, node, row, seen, model_cache, strict_loading_value)
          end
        end
      end
    end
  end
end
