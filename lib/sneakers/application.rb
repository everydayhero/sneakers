module Sneakers
  Application = Struct.new(:public_key, :secret_key) do
    alias_method :name, :public_key
    alias_method :key, :secret_key
  end
end
