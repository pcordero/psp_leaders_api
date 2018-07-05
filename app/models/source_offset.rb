class SourceOffset < ApplicationRecord
  
  validates_presence_of :date_created_at, :state, :scope1, :offset
  
  def self.find_or_create(date_created_at, state, scope1, scope2, offset)
    so = SourceOffset.where(:date_created_at => date_created_at, :state => state, :scope1 => scope1, :scope2 => scope2).first
    
    return so if so
    
    so = SourceOffset.new
    so.date_created_at = date_created_at
    so.state = state
    so.scope1 = scope1
    so.scope2 = scope2
    so.offset = 0
    
    if so.save
      return so
    else
      raise so.errors.full_messages.inspect
    end    
  end
  
  def self.save_offset_position(state, scope1, scope2, offset)
    so = SourceOffset.new
    so.date_created_at = Date.today
    so.state = state
    so.scope1 = scope1
    so.scope2 = scope2
    so.offset = offset
    
    if so.save
      return so
    else
      raise so.errors.full_messages.inspect
    end    
  end
  
  def self.get_last(state, scope1, scope2)
    so = SourceOffset.where(:state => state, :scope1 => scope1, :scope2 => scope2).order("date_created_at DESC").limit(1).first
    return so if so
  end
end
