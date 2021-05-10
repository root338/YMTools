
class HashE
  # 判读 Hash 是否包含多个 key 值
  def self.hasKeys(keys, hash)
    return keys.all? { |key|
      hash.key? key
    }
  end
end
