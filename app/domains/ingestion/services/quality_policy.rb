module Ingestion
  class QualityPolicy
    # returns [pass:boolean, reasons:Array<String>]
    def self.check(mapped)
      case mapped[:external_source]
      when "tmdb"
        va = mapped.dig(:metadata, :quality_signals, :vote_average).to_f
        vc = mapped.dig(:metadata, :quality_signals, :vote_count).to_i
        return [true, []] if va >= 6.5 && vc >= 1000
        return [false, ["tmdb_low_rating_or_votes (va=\#{va}, vc=\#{vc})"]]
      else
        [true, []]
      end
    end
  end
end
