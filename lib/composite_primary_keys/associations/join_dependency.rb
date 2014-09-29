module ActiveRecord
  module Associations
    class JoinDependency
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

      def instantiate(result_set, aliases)
        primary_key = aliases.column_alias(join_root, join_root.primary_key)

        seen = Hash.new { |h,parent_klass|
          h[parent_klass] = Hash.new { |i,parent_id|
            i[parent_id] = Hash.new { |j,child_klass| j[child_klass] = {} }
          }
        }

        model_cache = Hash.new { |h,klass| h[klass] = {} }
        parents = model_cache[join_root]
        column_aliases = aliases.column_aliases join_root

        result_set.each { |row_hash|
          # CPK
          primary_id = if primary_key.kind_of?(Array)
                         primary_key.map {|key| row_hash[key]}
                       else
                         row_hash[primary_key]
                       end
          parent = parents[primary_id] ||= join_root.instantiate(row_hash, column_aliases)
          construct(parent, join_root, row_hash, result_set, seen, model_cache, aliases)
        }

        parents.values
      end

      def construct(ar_parent, parent, row, rs, seen, model_cache, aliases)
        primary_id  = ar_parent.id

        parent.children.each do |node|
          if node.reflection.collection?
            other = ar_parent.association(node.reflection.name)
            other.loaded!
          else
            if ar_parent.association_cache.key?(node.reflection.name)
              model = ar_parent.association(node.reflection.name).target
              construct(model, node, row, rs, seen, model_cache, aliases)
              next
            end
          end

          key = aliases.column_alias(node, node.primary_key)

          # CPK
          if key.is_a?(Array)
            id = Array(key).map do |column_alias|
              value = row[column_alias]
            end
            # At least the first value in the key has to be set.  Should we require all values to be set?
            next if id.first.nil?
          else
            id = row[key]
            next if id.nil?
          end

          model = seen[parent.base_klass][primary_id][node.base_klass][id]

          if model
            construct(model, node, row, rs, seen, model_cache, aliases)
          else
            model = construct_model(ar_parent, node, row, model_cache, id, aliases)
            seen[parent.base_klass][primary_id][node.base_klass][id] = model
            construct(model, node, row, rs, seen, model_cache, aliases)
          end
        end
      end
    end
  end
end
