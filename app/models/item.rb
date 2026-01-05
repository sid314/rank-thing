class Item < ApplicationRecord
  belongs_to :category
  K = 32
  def self.update_rankings(winner, loser)
    winner_win_probability = 1.0/(1.0 + 10**(loser.ranking - winner.ranking)/400)
    loser_win_probability = 1.0/(1.0 + 10**(winner.ranking - loser.ranking)/400)

    winner_ranking = winner.ranking + K * (1 + winner_win_probability)

    loser_ranking = loser.ranking + K * (0 - loser_win_probability)
    winner.update(ranking: winner_ranking)
    loser.update(ranking: loser_ranking)
  end
end
