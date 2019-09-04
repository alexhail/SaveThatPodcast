class Object

  def to_oid_safe
    if BSON::ObjectId.legal?(self)
      BSON::ObjectId(self)
    else
      return nil
    end
  end
end
