defmodule LoanSchedule do
  def perform(apr, monthly_payment, balance) do
    schedule = calculate(apr, monthly_payment, balance, 0, %{})
    total_payments = Map.keys(schedule) |> Enum.max
    total_paid = Map.values(schedule) |> Enum.reduce(0, fn(loan, acc) -> loan[:monthly_payment] + acc end)
    [
      payment_schedule: schedule,
      loan_details: %{
        apr: apr,
        monthly_payment: monthly_payment,
        initial_balance: balance,
        total_payments: total_payments,
        total_paid: total_paid
      }
    ]
  end

  def calculate(apr, monthly_payment, balance, payments, schedule_map) when balance < monthly_payment do
    IO.puts "We are there! Last payment of: #{balance}"
    IO.puts "We've made #{payments + 1} payments"
    monthly_interest_payment = ((apr / 12) * balance)
    current_payment_period = payments + 1
    final_payment = balance + monthly_interest_payment
    total_paid = (payments * monthly_payment) + final_payment

    current_period = [
      current_balance: 0,
      total_paid: total_paid,
      principal_payment: balance,
      interest_payment: monthly_interest_payment,
      current_payment_period: current_payment_period,
      monthly_payment: final_payment
    ]
    Map.put(schedule_map, current_payment_period, current_period)
  end

  def calculate(apr, monthly_payment, balance, payments, schedule_map) do
    %{interest: interest_payment, principal: principal_payment} = current_payments(apr, balance, monthly_payment)

    if principal_payment < 0 do
      raise "You can't pay this loan. Your minimum payment must be higher than #{interest_payment}"
    end

    if principal_payment == 0 do
      raise "You are paying just below the minimum payment"
    end

    current_payment_period = payments + 1
    next_month_balance = balance - principal_payment
    total_paid = current_payment_period * monthly_payment
    # ^^ is this right?

    current_period = [
      apr: apr,
      current_balance: next_month_balance,
      total_paid: total_paid,
      principal_payment: principal_payment,
      interest_payment: interest_payment,
      current_payment_period: current_payment_period,
      monthly_payment: monthly_payment
    ]
    new_payment_schedule = Map.put(schedule_map, current_payment_period, current_period)

    calculate(apr, monthly_payment, next_month_balance, current_payment_period, new_payment_schedule)
  end

  def current_payments(apr, balance, monthly_payment) do
    monthly_interest_payment = ((apr / 12) * balance)
    monthly_principal_payment = monthly_payment - monthly_interest_payment

    %{
      interest: monthly_interest_payment,
      principal: monthly_principal_payment
    }
  end
end

