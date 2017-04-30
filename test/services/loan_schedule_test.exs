defmodule DefeatTheLoan.LoanScheduleTest do
  use ExUnit.Case, async: true

  describe "current_payments/3" do
    test "with valid args returns the interest and principal owed" do
      apr = 0.12
      balance = 100
      monthly = 10
      payment = LoanSchedule.current_payments(apr, balance, monthly)

      assert %{interest: 1.0, principal: 9.0} = payment
    end
  end
end
