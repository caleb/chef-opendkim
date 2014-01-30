actions :create, :delete
default_action :create

attribute :name, :name_attribute => true

attribute :selector, :kind_of => [String], :default => DateTime.now.strftime('%b%Y').downcase
attribute :domain, :kind_of => [String], :default => nil
attribute :private_key, :kind_of => [String,NilClass], :default => nil
attribute :signatures, :kind_of => [Array,String], :default => nil

attribute :bits, :kind_of => [Numeric,String], :default => 1024
