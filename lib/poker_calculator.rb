class PokerCalculator

  RANK = (0..12).to_a*4.freeze
  SUIT = ((0..3).to_a*13).sort.freeze
  CHOOSE2 = [0, 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153, 171, 190, 210, 231, 253, 276, 300, 325, 351, 378, 406, 435, 465, 496, 528, 561, 595, 630, 666, 703, 741, 780, 820, 861, 903, 946, 990, 1035, 1081, 1128, 1176, 1225, 1275, 1326, 1378, 1431, 1485, 1540, 1596, 1653, 1711, 1770, 1830, 1891, 1953, 2016, 2080].freeze
  CHOOSE3 = [0, 0, 0, 1, 4, 10, 20, 35, 56, 84, 120, 165, 220, 286, 364, 455, 560, 680, 816, 969, 1140, 1330, 1540, 1771, 2024, 2300, 2600, 2925, 3276, 3654, 4060, 4495, 4960, 5456, 5984, 6545, 7140, 7770, 8436, 9139, 9880, 10660, 11480, 12341, 13244, 14190, 15180, 16215, 17296, 18424, 19600, 20825, 22100, 23426, 24804, 26235, 27720, 29260, 30856, 32509, 34220, 35990, 37820, 39711, 41664, 43680].freeze
  CHOOSE4 = [0, 0, 0, 0, 1, 5, 15, 35, 70, 126, 210, 330, 495, 715, 1001, 1365, 1820, 2380, 3060, 3876, 4845, 5985, 7315, 8855, 10626, 12650, 14950, 17550, 20475, 23751, 27405, 31465, 35960, 40920, 46376, 52360, 58905, 0x101fd, 0x12057, 0x1414b, 0x164fe, 0x18b96, 0x1b53a, 0x1e212, 0x21247, 0x24603, 0x27d71, 0x2b8bd, 0x2f814, 0x33ba4, 0x3839c, 0x3d02c, 0x42185, 0x477d9, 0x4d35b, 0x5343f, 0x59aba, 0x60702, 0x6794e, 0x6f1d6, 0x770d3, 0x7f67f, 0x88315, 0x916d1, 0x9b1f0, 0xa54b0].freeze
  CHOOSE5 = [0, 0, 0, 0, 0, 1, 6, 21, 56, 126, 252, 462, 792, 1287, 2002, 3003, 4368, 6188, 8568, 11628, 15504, 20349, 26334, 33649, 42504, 53130, 0x100f4, 0x13b5a, 0x17fe8, 0x1cfe3, 0x22caa, 0x297b7, 0x312a0, 0x39f18, 0x43ef0, 0x4f418, 0x5c0a0, 0x6a6b9, 0x7a8b6, 0x8c90d, 0xa0a58, 0xb6f56, 0xcfaec, 0xeb026, 0x109238, 0x12a47f, 0x14ea82, 0x1767f3, 0x1a20b0, 0x1d18c4, 0x205468, 0x23d804, 0x27a830, 0x2bc9b5, 0x30418e, 0x3514e9, 0x3a4928, 0x3fe3e2, 0x45eae4, 0x4c6432, 0x535608, 0x5ac6db, 0x62bd5a, 0x6b406f, 0x745740, 0x7e0930].freeze

  attr_reader :outcome
  attr_reader :aflag
  attr_reader :player_cards
  attr_reader :community_cards
  attr_reader :ai4
  attr_accessor :hand_rank

  def initialize(opts = {})
    @outcome = Array.new(10) { Array.new(11) { 0 }}
    @aflag = Array.new(52) { false }
    @player_count = 0
    puts "Generating Structures."

    @hand_rank = Array.new(2598960)

    puts "Preparing Data."
    prepare_data
    puts "Data Prepared."
  end

  def to_s
    puts "PokerCalculator"
  end

  def output(player_set, community, folded)
    pcount = player_set.count
    pcards = player_set.collect { |p| [card_to_val(p[0]), card_to_val(p[1])] }
    ccards = (community || []).collect { |c| card_to_val(c) }
    fcards = (folded || []).collect { |f| card_to_val(f) }
    analyze_scenario(pcount, pcards, ccards, fcards)
  end

  def card_to_val(card)
    card_val = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"].index(card[0].upcase)
    suit_val = ["C", "D", "H", "S"].index(card[1].upcase)
    return ((13*suit_val) + card_val)
  end

  def analyze_scenario(player_count, player_cards, community_cards, folded_cards)
    @outcome = Array.new(10) { Array.new(11) {0}}
    @aflag = Array.new(52) { false }
    @player_count = player_count
    @community_cards = community_cards
    @player_cards = player_cards

    player_count.times do |j|
      @aflag[@player_cards[j][0]] = true
      @aflag[@player_cards[j][1]] = true
    end

    @community_cards.each do |k|
      @aflag[k] = true
    end

    folded_cards.each do |l|
      @aflag[l] = true
    end

    @top_hands = Array.new(player_count) { 0 }

    if @community_cards.length == 0
      analyze_0cards
    elsif @community_cards.length == 3
      analyze_3cards
    elsif @community_cards.length == 4
      analyze_4cards
    elsif @community_cards.length == 5
      analyze_5cards
    else
      # can't only have one or two
    end

    summary = []
    hands = 0
    (0..@player_count).each do |player|
      hands += @outcome[0][player]
    end

    (0...@player_count).each do |player|
      ties = 0
      (2..@player_count).each do |shared_player|
        ties += @outcome[player][shared_player]
      end
      summary << { :player_id => player, :win_pct => @outcome[player][1] / hands.to_f, :tie_pct => ties / hands.to_f }
    end

    return summary
  end

  def prepare_data
    i = 0
    (4...52).each do |j|
      (3...j).each do |k|
        (2...k).each do |l|
          (1...l).each do |i1|
            (0...i1).each do |j1|
              hand_rank[i] = get_hand_rank(j1, i1, l, k, j)
              i += 1
            end
          end
        end
      end
    end
  end

  def get_hand_rank(*cards)
    if cards.count == 7
      get_hand_rank7(cards.sort)
    elsif cards.count == 5
      get_hand_rank5(cards.sort)
    else
      raise NoMethodError
    end
  end

private
  def get_hand_rank7(cards)
    temp01 = CHOOSE2[cards[1]]
    temp02 = CHOOSE3[cards[2]]
    temp03 = CHOOSE4[cards[3]]
    temp04 = CHOOSE5[cards[4]]
    temp11 = CHOOSE2[cards[2]]
    temp12 = CHOOSE3[cards[3]]
    temp13 = CHOOSE4[cards[4]]
    temp14 = CHOOSE5[cards[5]]
    temp21 = CHOOSE2[cards[3]]
    temp22 = CHOOSE3[cards[4]]
    temp23 = CHOOSE4[cards[5]]
    temp24 = CHOOSE5[cards[6]]

    temp31 = temp01 + cards[0]
    temp32 = temp11 + cards[0]
    temp33 = temp11 + cards[1]
    temp41 = temp02 + temp31
    temp42 = temp12 + temp31
    temp43 = temp12 + temp32
    temp51 = temp12 + temp33
    temp52 = temp22 + temp21
    temp53 = temp03 + temp41
    temp54 = temp13 + temp41
    temp61 = temp13 + temp42
    temp62 = temp13 + temp43
    temp63 = temp23 + temp52
    temp64 = temp24 + temp23

    ranks = []
    ranks << hand_rank[temp04 + temp53]
    ranks << hand_rank[temp14 + temp53]
    ranks << hand_rank[temp24 + temp53]
    ranks << hand_rank[temp14 + temp54]
    ranks << hand_rank[temp24 + temp54]
    ranks << hand_rank[temp64 + temp41]
    ranks << hand_rank[temp14 + temp61]
    ranks << hand_rank[temp24 + temp61]
    ranks << hand_rank[temp64 + temp42]
    ranks << hand_rank[temp64 + temp22 + temp31]
    ranks << hand_rank[temp14 + temp62]
    ranks << hand_rank[temp24 + temp62]
    ranks << hand_rank[temp64 + temp43]
    ranks << hand_rank[temp64 + temp22 + temp32]
    ranks << hand_rank[temp24 + temp63 + cards[0]]
    ranks << hand_rank[temp14 + temp13 + temp51]
    ranks << hand_rank[temp24 + temp13 + temp51]
    ranks << hand_rank[temp64 + temp51]
    ranks << hand_rank[temp64 + temp22 + temp33]
    ranks << hand_rank[temp24 + temp63 + cards[1]]
    ranks << hand_rank[temp24 + temp63 + cards[2]]

    return ranks.max
  end

  def get_hand_rank5(cards)
    ranks = cards.collect { |c| RANK[c] }.sort.reverse
    suits = cards.collect { |c| SUIT[c] }

    if suits.uniq.count > 1
      if (ranks[0] == ranks[3]) #four of a kind
        return 0x700000 | ranks[0] << 16 | ranks[4] << 12
      elsif (ranks[1] == ranks[4]) #four of a kind but something higher
        return 0x700000 | ranks[1] << 16 | ranks[0] << 12
      elsif (ranks[0] == ranks[2] && ranks[3] == ranks[4]) # full house, lower trips
        return 0x600000 | ranks[0] << 16 | ranks[3] << 12
      elsif (ranks[0] == ranks[1] && ranks[2] == ranks[4]) # full house, higher trips
        return 0x600000 | ranks[2] << 16 | ranks[0] << 12
      elsif (ranks[0] == ranks[2]) # three of a kind, lowest
        return 0x300000 | ranks[0] << 16 | ranks[4] << 12 | ranks[3] << 8
      elsif (ranks[1] == ranks[3]) # three of a kind, mid
        return 0x300000 | ranks[1] << 16 | ranks[4] << 12 | ranks[0] << 8
      elsif (ranks[2] == ranks[4]) # three of a kind, highest
        return 0x300000 | ranks[2] << 16 | ranks[1] << 12 | ranks[0] << 8
      elsif (ranks[0] == ranks[1] && ranks[2] == ranks[3]) # two pair, low
        return 0x200000 | ranks[2] << 16 | ranks[0] << 12 | ranks[4] << 8
      elsif (ranks[0] == ranks[1] && ranks[3] == ranks[4]) # two pair, split
        return 0x200000 | ranks[3] << 16 | ranks[0] << 12 | ranks[2] << 8
      elsif (ranks[1] == ranks[2] && ranks[3] == ranks[4]) # to pair, high
        return 0x200000 | ranks[3] << 16 | ranks[1] << 12 | ranks[0] << 8
      elsif (ranks[0] == ranks[1]) # pair low
        return 0x100000 | ranks[0] << 16 | ranks[4] << 12 | ranks[3] << 8 | ranks[2] << 4
      elsif (ranks[1] == ranks[2]) # pair nearlow
        return 0x100000 | ranks[1] << 16 | ranks[4] << 12 | ranks[3] << 8 | ranks[0] << 4
      elsif (ranks[2] == ranks[3]) # pair nearhigh
        return 0x100000 | ranks[2] << 16 | ranks[4] << 12 | ranks[1] << 8 | ranks[0] << 4
      elsif (ranks[3] == ranks[4]) # pair high
        return 0x100000 | ranks[3] << 16 | ranks[2] << 12 | ranks[1] << 8 | ranks[0] << 4
      elsif (ranks[4] - ranks[0] == 4) # straight
        return 0x400000 | ranks[4] << 16
      elsif (ranks[3] == 3 && ranks[4] == 12) # straight
        return 0x400000
      else # high card set
        return ranks[4] << 16 | ranks[3] << 12 | ranks[2] << 8 | ranks[1] << 4 | ranks[0]
      end
    end

    return 0x900000 if ranks[0] == 8

    return (0x800000 | ranks[4] << 16) if (ranks[4] - ranks[1]) == 4
    return (0x800000 | ranks[3] << 16) if (ranks[3] == 3 && ranks[4] == 12)
    return 0x500000 | ranks[4] << 16 | ranks[3] << 12 | ranks[2] << 8 | ranks[1] << 4 | ranks[0];
  end

  def analyze_0cards
    (4...52).each do |card1|
      next if @aflag[card1]
      (3...card1).each do |card2|
        next if @aflag[card2]
        (2...card2).each do |card3|
          next if @aflag[card3]
          (1...card3).each do |card4|
            next if @aflag[card4]
            (0...card4).each do |card5|
              next if @aflag[card5]
              high_hand = -1
              num_winners = 0
              (0...@player_count).each do |player|
                @top_hands[player] = get_hand_rank(@player_cards[player][0], @player_cards[player][1], card5, card4, card3, card2, card1)
                high_hand = @top_hands[player] unless (high_hand >= 0 && high_hand >= @top_hands[player])
              end

              (0...@player_count).each do |player|
                num_winners += 1 if @top_hands[player] == high_hand
              end

              (0...@player_count).each do |player|
                if @top_hands[player] == high_hand
                  @outcome[player][num_winners] += 1
                else
                  @outcome[player][0]
                end
              end
            end
          end
        end
      end
    end
  end

  def analyze_3cards
    (1...52).each do |card1|
      next if @aflag[card1]
      (0...card1).each do |card2|
        next if @aflag[card2]
        high_hand = -1
        num_winners = 0
        (0...@player_count).each do |player|
          @top_hands[player] = get_hand_rank(@player_cards[player][0], @player_cards[player][1], @community_cards[0], @community_cards[1], @community_cards[2], card2, card1)
          high_hand = [@top_hands[player], high_hand].max
        end

        (0...@player_count).each do |player|
          num_winners += 1 if @top_hands[player] == high_hand
        end

        (0...@player_count).each do |player|
          if @top_hands[player] == high_hand
            @outcome[player][num_winners] += 1
          else
            @outcome[player][0] += 1
          end
        end
      end
    end
  end

  def analyze_4cards
    (0...52).each do |card1|
      next if @aflag[card1]
      high_hand = -1
      num_winners = 0
      (0...@player_count).each do |player|
        @top_hands[player] = get_hand_rank(@player_cards[player][0], @player_cards[player][1], @community_cards[0], @community_cards[1], @community_cards[2], @community_cards[3], card1)
        high_hand = @top_hands[player] unless (high_hand >= 0 && high_hand >= @top_hands[player])
      end

      (0...@player_count).each do |player|
        num_winners += 1 if @top_hands[player] == high_hand
      end

      (0...@player_count).each do |player|
        if @top_hands[player] == high_hand
          @outcome[player][num_winners] += 1
        else
          @outcome[player][0] += 1
        end
      end
    end
  end

  def analyze_5cards
    high_hand = -1
    num_winners = 0
    (0...@player_count).each do |player|
      @top_hands[player] = get_hand_rank(@player_cards[player][0],@player_cards[player][1],@community_cards[0],@community_cards[1],@community_cards[2],@community_cards[3],@community_cards[4])
      high_hand = @top_hands[player] unless (high_hand >= 0 && high_hand >= @top_hands[player])
    end

    (0...@player_count).each do |player|
      num_winners += 1 if @top_hands[player] == high_hand
    end

    (0...@player_count).each do |player|
      if @top_hands[player] == high_hand
        @outcome[player][num_winners] += 1
      else
        @outcome[player][0] += 1
      end
    end
  end
end


=begin
  t = Time.now
  pc = PokerCalculator.new
  puts Time.now - t
  puts pc.output([ ["AH","AC"],
                   ["2H","2C"] ],
                 [ "AS", "AD", "3D" ],
                 [])
  puts Time.now - t
=end
