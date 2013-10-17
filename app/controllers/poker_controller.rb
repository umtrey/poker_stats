class PokerController < ApplicationController
  def index
    if table = params
      results = CalculatorHandler.process(table)
    else
      results = []
    end

    render :json => results
  end
end
