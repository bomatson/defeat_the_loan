defmodule DefeatTheLoan.RecommendationController do
  use DefeatTheLoan.Web, :controller

  def create(conn, params) do
    IO.inspect params
    loans = [
      LoanSchedule.perform(0.12, 633.61, 19000),
      LoanSchedule.perform(0.06, 400.01, 30000),
      LoanSchedule.perform(0.08, 300.01, 10000)
    ]

    budget = LoanService.current_monthly_payment(loans)
    coulda_paid = LoanService.total(loans)

    recommendations = Allocator.perform(loans, budget)

    IO.inspect List.last(recommendations)[:total_paid]
    IO.puts "vs"
    IO.inspect coulda_paid

    render conn, "show.html", recommendations: recommendations
  end
end
