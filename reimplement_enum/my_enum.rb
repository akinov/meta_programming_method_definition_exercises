module MyEnum
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enum(definitions)
      key, attrs = definitions.first

      # Arrayだったらいい感じにする
      if (attrs.is_a?(Array))
        attrs = attrs.each_with_index.map {|value, index| [value, index] }.to_h
      end

      # キーからsymを返す
      self.define_method key do
        attrs.key(instance_variable_get("@#{key}"))
      end

      attrs.each do |attr, value|
        # ?
        self.define_method "#{attr}?" do
          instance_variable_get("@#{key}") == value
        end

        # !
        self.define_method "#{attr}!" do
          instance_variable_set "@#{key}", value
        end

        # =
        self.define_method "#{attr}=" do |value|
          instance_variable_set "@#{key}", value
        end

        # 検索
        self.define_singleton_method "#{attr}" do
          $database.select { |data| data.send(key) == attr }
        end

        # not_xxx
        self.define_singleton_method "not_#{attr}" do
          $database.reject { |data| data.send(key) == attr }
        end
      end
    end
  end
end
