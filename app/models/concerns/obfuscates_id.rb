# extracted from
# https://github.com/bullet-train-co/bullet_train-core/blob/main/bullet_train-obfuscates_id/app/models/concerns/obfuscates_id.rb

# https://github.com/sqids/sqids-ruby
module ObfuscatesId
  extend ActiveSupport::Concern

  class_methods do
    def sqids
      # ⚠️ Changing anything in this method will invalidate any URLs with obfuscated IDs that are in the wild.
      # You should not change any of these settings after going live unless you're OK breaking links in sent emails,
      # breaking bookmarks to pages within your application, etc. For this reason, we don't want the Sqids salt
      # configurable via an ENV value.
      @sqids ||= Sqids.new(
        alphabet: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
        min_length: 6,
        salt: "Default ID Obfuscation Salt for #{name}"
      )
    end

    def encode_id(id)
      sqids.encode([id])
    end

    def decode_id(id)
      if id.is_a?(Array)
        id.map { |single_id| decode_single_id(single_id) }
      else
        decode_single_id(id)
      end
    end

    def decode_single_id(id)
      return id if id.to_i.positive?

      sqids.decode(id).first
    end

    def find(*ids)
      super(*ids.map { |id| decode_id(id) })
    end

    def relation
      super.tap { |r| r.extend ClassMethods }
    end

    def has_many(*args, &block)
      options = args.extract_options!
      options[:extend] = Array(options[:extend]).push(ClassMethods)
      super(*args, **options, &block)
    end

    def find_by_obfuscated_id(id)
      find_by(id: decode_id(id))
    end
  end

  def obfuscated_id
    @obfuscated_id ||= self.class.encode_id(id)
  end

  def to_param
    obfuscated_id
  end
end
