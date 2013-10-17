require 'json'

module CalculatorHandler
  def self.process(request_hash)
    player_tracker = {}

    players = request_hash["players"]
    community_cards = request_hash["community_cards"]

    folded_players = []
    active_card_sets = []
    folded_cards = []

    order = 0
    players.each do |key, val|
      if val["folded"]
        folded_players << key
        folded_cards += val["cards"]
      else
        player_tracker[order] = key
        order += 1
        active_card_sets << val["cards"]
      end
    end

    results = CALCULATOR.output(active_card_sets,community_cards,folded_cards)
    results.each do |result|
      result[:player_id] = player_tracker[result[:player_id]]
    end

    folded_players.each do |player|
      res = { player_id: player, win_pct: 0.0, tie_pct: 0.0 }
      results << res
    end

    results.sort { |a,b| b[:win_pct] <=> a[:win_pct] }
  end
end
