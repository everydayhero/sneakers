module Sneakers
  Application = Struct.new(:name, :key, :signed_attributes, :unsigned_attributes) do
    def attributes
      signed_attributes + unsigned_attributes
    end
  end
end
