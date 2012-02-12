#--
# Copyright (c) 2006-2012 Nic Williams and Charlie Savage
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

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined?(ActiveRecord)
  require 'rubygems'
  gem 'activerecord', '~> 3.2.0'
  require 'active_record'
end

# AR files we override
require 'active_record/fixtures'
require 'active_record/persistence'
require 'active_record/relation'
require 'active_record/sanitization'

require 'active_record/associations/association'
require 'active_record/associations/association_scope'
require 'active_record/associations/has_and_belongs_to_many_association'
require 'active_record/associations/has_many_association'
require 'active_record/associations/join_dependency'
require 'active_record/associations/join_dependency/join_part'
require 'active_record/associations/join_dependency/join_association'
require 'active_record/associations/preloader/association'
require 'active_record/associations/preloader/belongs_to'
require 'active_record/associations/preloader/has_and_belongs_to_many'

require 'active_model/dirty'

require 'active_record/attribute_methods/dirty'
require 'active_record/attribute_methods/read'
require 'active_record/attribute_methods/write'

require 'active_record/connection_adapters/abstract_adapter'

require 'active_record/relation/calculations'
require 'active_record/relation/finder_methods'
require 'active_record/relation/query_methods'

require 'active_record/validations/uniqueness'


# CPK files
require 'composite_primary_keys/base'
require 'composite_primary_keys/composite_arrays'
require 'composite_primary_keys/composite_predicates'
require 'composite_primary_keys/fixtures'
require 'composite_primary_keys/persistence'
require 'composite_primary_keys/relation'
require 'composite_primary_keys/sanitization'
require 'composite_primary_keys/version'

require 'composite_primary_keys/associations/association'
require 'composite_primary_keys/associations/association_scope'
require 'composite_primary_keys/associations/has_and_belongs_to_many_association'
require 'composite_primary_keys/associations/has_many_association'
require 'composite_primary_keys/associations/join_dependency'
require 'composite_primary_keys/associations/join_dependency/join_part'
require 'composite_primary_keys/associations/join_dependency/join_association'
require 'composite_primary_keys/associations/preloader/association'
require 'composite_primary_keys/associations/preloader/belongs_to'
require 'composite_primary_keys/associations/preloader/has_and_belongs_to_many'

require 'composite_primary_keys/dirty'

require 'composite_primary_keys/attribute_methods/dirty'
require 'composite_primary_keys/attribute_methods/read'
require 'composite_primary_keys/attribute_methods/write'

require 'composite_primary_keys/connection_adapters/abstract_adapter'
require 'composite_primary_keys/connection_adapters/abstract/connection_specification_changes'

require 'composite_primary_keys/relation/calculations'
require 'composite_primary_keys/relation/finder_methods'
require 'composite_primary_keys/relation/query_methods'

require 'composite_primary_keys/validations/uniqueness'