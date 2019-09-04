module Modules::StatBuilder
  
  def initialize_statistics!
    ::StatObject.all.each do |obj|
      obj.data.each do |data_hash|
        unless data_hash["source"].empty?
        end
      end

      obj.update
    end
  end
end