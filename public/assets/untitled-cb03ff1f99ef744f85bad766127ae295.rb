class A
	include ClassLevelInheritableAttributes

	def self.define_metadata_methods
		puts "KEY LIST: #{self.keys.inspect}"
	end
end


module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)    
  end
  
  module ClassMethods
  	def inherited(subclass)
        instance_var = "@#{keys}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
    end
  end
end