# app/contexts/ingestion/flow/quality_policy.rb
# frozen_string_literal: true

# This defines the constant Ruby is looking for:
# Ingestion::Flow::QualityPolicy
module Ingestion
  class Flow
    class QualityPolicy
      VOTE_AVG_MIN   = (ENV['TMDB_VOTE_AVG_MIN']   || '6.5').to_f
      VOTE_COUNT_MIN = (ENV['TMDB_VOTE_COUNT_MIN'] || '1000').to_i

      # @param mapped [Hash] a normalized hash the Flow uses (should include vote_average, vote_count)
      # @return [Array(Boolean, Array<String>)] pass?, reasons
      def self.check(mapped)
        puts "[QUALITY] start vote_avg_min=#{VOTE_AVG_MIN} vote_count_min=#{VOTE_COUNT_MIN}"

        va = fetch_float(mapped, :vote_average)
        vc = fetch_int(mapped,   :vote_count)

        reasons = []
        if va.nil?
          reasons << "missing vote_average"
        elsif va < VOTE_AVG_MIN
          reasons << "vote_average #{va} < #{VOTE_AVG_MIN}"
        end

        if vc.nil?
          reasons << "missing vote_count"
        elif vc < VOTE_COUNT_MIN
          reasons << "vote_count #{vc} < #{VOTE_COUNT_MIN}"
        end

        pass = reasons.empty?
        puts "[QUALITY] result pass=#{pass} reasons=#{reasons.join('; ')}"
        [pass, reasons]
      end

      # ---- helpers ----
      def self.fetch_float(h, key)
        v = fetch(h, key)
        return nil if v.nil?
        v.to_f
      end

      def self.fetch_int(h, key)
        v = fetch(h, key)
        return nil if v.nil?
        v.to_i
      end

      def self.fetch(h, key)
        return nil if h.nil?
        # symbol or string access
        if h.respond_to?(:key?)
          return h[key] if h.key?(key)
          ks = key.to_s
          return h[ks] if h.key?(ks)
        end
        nil
      rescue
        nil
      end
    end
  end
end
