defmodule Allocator do
  def perform(loans, budget) do
    rec = [
      recommendation: LoanService.recommend(loans, budget),
      total_paid: 0,
      allocation_order: 0
    ]
    allocate(rec, budget, [])
  end

  defp allocate(rec, budget, acc) do


    if(rec[:recommendation][:reallocate]) do
      recommendation = rec[:recommendation]
      allocation_order = rec[:allocation_order] + 1
      existing_loans = recommendation[:loans]

      # what if two loans are paid off at once?
      paid_off_loan = Enum.min_by(existing_loans, fn(loan) -> loan[:loan_details][:total_payments] end)
      current_payment_period = paid_off_loan[:loan_details][:total_payments]

      remaining_loans = Enum.map(existing_loans, fn(loan) -> 
       Map.get(loan[:payment_schedule], current_payment_period)
      end)

      total_paid =
        Enum.map(remaining_loans, fn(loan) -> loan.total_paid end)
        |> Enum.sum

      leftover = Enum.filter(remaining_loans, fn(loan) -> loan.current_balance > 0 end)

      new_allocation = Enum.map(leftover, fn(loan) ->
        LoanSchedule.perform(loan.apr, loan.monthly_payment, loan.current_balance)
      end)

      new_rec = [
        recommendation: LoanService.recommend(new_allocation, budget),
        total_paid: total_paid + rec[:total_paid],
        allocation_order: allocation_order
      ]

      allocate(new_rec, budget, acc ++ [new_rec])
    else
      paid_off_loan = List.first(rec[:recommendation][:loans])

      last_total_paid = LoanService.loan_total(paid_off_loan)
      current_payment_period = paid_off_loan[:loan_details][:total_payments]
      allocation_order = rec[:allocation_order] + 1

      acc ++ [[
        recommendation: [],
        total_paid: last_total_paid + rec[:total_paid],
        allocation_order: allocation_order
      ]]
    end
  end
end
