#--
# Copyright (c) 2006-2016 Nic Williams and Charlie Savage
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

unless defined?(ActiveRecord)
  require 'rubygems'
  gem 'activerecord', '~>6.1.0'
  require 'active_record'
end

# ActiveModel files we override
# _write_attribute
require 'active_model/attribute_assignment'

# ActiveRecord files we override
require 'active_record/attribute_methods'
require 'active_record/autosave_association'
require 'active_record/counter_cache'
require 'active_record/fixtures'
require 'active_record/model_schema'
require 'active_record/persistence'
require 'active_record/reflection'
require 'active_record/relation'
require 'active_record/sanitization'
require 'active_record/transactions'

require 'active_record/associations/association'
require 'active_record/associations/association_scope'
require 'active_record/associations/foreign_association'
require 'active_record/associations/has_many_association'
require 'active_record/associations/has_many_through_association'
require 'active_record/associations/join_dependency'
require 'active_record/associations/preloader/association'
require 'active_record/associations/singular_association'
require 'active_record/associations/collection_association'
require 'active_record/associations/through_association'

require 'active_record/attribute_methods/primary_key'
require 'active_record/attribute_methods/read'
require 'active_record/attribute_methods/write'
require 'active_record/nested_attributes'

require 'active_record/connection_adapters/abstract/database_statements'
require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/postgresql/database_statements'

require 'active_record/relation/where_clause'
require 'active_record/table_metadata'

# CPK overrides
require_relative 'composite_primary_keys/active_model/attribute_assignment'
require_relative 'composite_primary_keys/attribute_methods'
require_relative 'composite_primary_keys/autosave_association'
require_relative 'composite_primary_keys/persistence'
require_relative 'composite_primary_keys/base'
require_relative 'composite_primary_keys/core'
require_relative 'composite_primary_keys/composite_arrays'
require_relative 'composite_primary_keys/composite_predicates'
require_relative 'composite_primary_keys/counter_cache'
require_relative 'composite_primary_keys/fixtures'
require_relative 'composite_primary_keys/reflection'
require_relative 'composite_primary_keys/relation'
require_relative 'composite_primary_keys/sanitization'
require_relative 'composite_primary_keys/transactions'
require_relative 'composite_primary_keys/version'

require_relative 'composite_primary_keys/associations/association'
require_relative 'composite_primary_keys/associations/association_scope'
require_relative 'composite_primary_keys/associations/foreign_association'
require_relative 'composite_primary_keys/associations/has_many_association'
require_relative 'composite_primary_keys/associations/has_many_through_association'
require_relative 'composite_primary_keys/associations/join_association'
require_relative 'composite_primary_keys/associations/preloader/association'
require_relative 'composite_primary_keys/associations/collection_association'
require_relative 'composite_primary_keys/associations/through_association'

require_relative 'composite_primary_keys/attribute_methods/primary_key'
require_relative 'composite_primary_keys/attribute_methods/read'
require_relative 'composite_primary_keys/attribute_methods/write'
require_relative 'composite_primary_keys/nested_attributes'

require_relative 'composite_primary_keys/connection_adapters/abstract/database_statements'
require_relative 'composite_primary_keys/connection_adapters/abstract_adapter'
require_relative 'composite_primary_keys/connection_adapters/postgresql/database_statements'
require_relative 'composite_primary_keys/connection_adapters/sqlserver/database_statements'

require_relative 'composite_primary_keys/relation/batches'
require_relative 'composite_primary_keys/relation/where_clause'
require_relative 'composite_primary_keys/relation/calculations'
require_relative 'composite_primary_keys/relation/finder_methods'
require_relative 'composite_primary_keys/relation/predicate_builder/association_query_value'
require_relative 'composite_primary_keys/relation/query_methods'

require_relative 'composite_primary_keys/validations/uniqueness'

require_relative 'composite_primary_keys/composite_relation'

require_relative 'composite_primary_keys/arel/to_sql'
require_relative 'composite_primary_keys/arel/sqlserver'
require_relative 'composite_primary_keys/table_metadata'