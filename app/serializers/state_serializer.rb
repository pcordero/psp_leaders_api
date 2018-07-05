class StateSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :region, :is_state
end
