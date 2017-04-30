defmodule LoanService do
  def recommend(loans, budget) do
    best_payoff_schedule(loans, budget)
  end

  def best_payoff_schedule(loans, budget) do
    minimum_budget = minimum_budget(loans)
    fudge_factor = budget - minimum_budget

    high_loans = high_interest_loans(loans)
    low_loans = low_interest_loans(loans)

    new_loans = unless Enum.empty?(high_loans) do
      # first_allocation

      new_total = total(high_loans)
      high_interest_loans = Enum.map(high_loans, fn(loan) -> 
        additional = (loan_total(loan)/new_total) * fudge_factor
        new_monthly_payment = loan_minimum(loan) + additional
        balance = loan[:loan_details][:initial_balance]

        LoanSchedule.perform(loan_apr(loan), new_monthly_payment, balance)
      end)

      low_interest_loans = Enum.map(low_loans, fn(loan) ->
        new_monthly_payment = loan_minimum(loan)
        balance = loan[:loan_details][:initial_balance]

        LoanSchedule.perform(loan_apr(loan), new_monthly_payment, balance)
      end)

      new_loans = high_interest_loans ++ low_interest_loans
      [
        loans: new_loans,
        reallocate: true 
      ]
    else
      # only allocation
      new_total = total(low_loans)
      new_loans = Enum.map(low_loans, fn(loan) -> 
        additional = (loan_total(loan)/new_total) * fudge_factor
        new_monthly_payment = loan_minimum(loan) + additional
        balance = loan[:loan_details][:initial_balance]

        LoanSchedule.perform(loan_apr(loan), new_monthly_payment, balance)
      end)
      [
        loans: new_loans,
        reallocate: false
      ]
    end

    new_loans
  end

  def high_interest_loans(loans) do
    Enum.filter(loans, fn(loan) -> loan_apr(loan) > 0.06 end)
  end

  def low_interest_loans(loans) do
    Enum.filter(loans, fn(loan) -> loan_apr(loan) <= 0.06 end)
  end

  def find_worst_loan(loans) do
    Enum.max_by(loans, fn(loan) -> loan_apr(loan) end)
  end

  def current_monthly_payment(loans) do
    Enum.reduce(loans, 0, fn(loan, acc) -> loan_monthly_payment(loan) + acc end)
  end

  def total(loans) do
    Enum.reduce(loans, 0, fn(loan, acc) -> loan_total(loan) + acc end)
  end

  def loan_monthly_payment(loan) do
    loan[:loan_details][:monthly_payment]
  end

  def loan_apr(loan) do
    loan[:loan_details][:apr]
  end

  def minimum_budget(loans) do
    Enum.reduce(loans, 0, fn(loan, acc) -> loan_minimum(loan) + acc end)
  end

  def loan_minimum(loan) do
    balance = loan[:loan_details][:initial_balance]
    ((loan_apr(loan) / 12) * balance) + 0.01
  end

  def loan_total(loan) do
    loan[:loan_details][:total_paid]
  end
end

