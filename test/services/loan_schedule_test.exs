defmodule DefeatTheLoan.LoanScheduleTest do
  use ExUnit.Case, async: true

  describe "current_payments/3" do
    test "with valid args returns the interest and principal owed" do
      apr = 0.12
      balance = 100
      monthly = 10
      payment = LoanSchedule.current_payment(apr, balance, monthly)

      assert {:ok, %{interest_payment: 1.0, principal_payment: 9.0}} = payment
    end

    test "with a negative balance returns an error" do
      apr = 0.12
      balance = -100
      monthly = 10
      payment = LoanSchedule.current_payment(apr, balance, monthly)

      assert {:error, :negative_balance} = payment
    end

    test "with a negative monthly returns an error" do
      apr = 0.12
      balance = 100
      monthly = -10
      payment = LoanSchedule.current_payment(apr, balance, monthly)

      assert {:error, :negative_monthly_payment} = payment
    end
  end

  describe "calculate/3" do
    test "returns the first monthly payment" do
      apr = 0.12
      balance = 100
      monthly_payment = 10

      payment_schedule = LoanSchedule.calculate(apr, monthly_payment, balance, 0, %{})
      expected_first_payment = %MonthlyPayment{
        apr: 0.12,
        current_balance: 91.0,
        interest_payment: 1.0,
        monthly_payment: 10,
        principal_payment: 9.0,
        total_paid: 10,
      }
      assert Map.get(payment_schedule, 1) == expected_first_payment
    end

    test "returns any future payments" do
      apr = 0.12
      balance = 100
      monthly_payment = 10

      payment_schedule = LoanSchedule.calculate(apr, monthly_payment, balance, 0, %{})
      expected_fifth_payment = %MonthlyPayment{
        apr: 0.12,
        current_balance: 54.09095491000001,
        interest_payment: 0.63456391,
        monthly_payment: 10,
        principal_payment: 9.36543609,
        total_paid: 50,
      }
      assert Map.get(payment_schedule, 5) == expected_fifth_payment
    end

    test "returns the final payment" do
      apr = 0.12
      balance = 100
      monthly_payment = 10

      payment_schedule = LoanSchedule.calculate(apr, monthly_payment, balance, 0, %{})
      expected_final_payment = %MonthlyPayment{
        current_balance: 0,
        interest_payment: 0.058400871299159544,
        monthly_payment: 5.898488001215114,
        principal_payment: 5.840087129915954,
        total_paid: 105.89848800121511,
      }
      assert Map.get(payment_schedule, 11) == expected_final_payment
    end
  end
end
