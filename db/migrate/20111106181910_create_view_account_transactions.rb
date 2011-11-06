class CreateViewAccountTransactions < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view account_transactions as
      with account_transactions_with_line_saldo as (
        select accounts.id as "account_id",
          transactions.id as "transaction_id", date, text,
          case when debit_account_id=accounts.id  then amount
            else 0
          end as "debit_amount",
          case when credit_account_id=accounts.id then amount
            else 0
          end as "credit_amount",
          case when debit_account_id  = accounts.id then amount
            when credit_account_id = accounts.id then -amount
            else NULL
          end as "line_saldo"
        from accounts, transactions where debit_account_id=accounts.id or credit_account_id=accounts.id order by account_id,date,transactions.id
      )
      select
        *,
        sum(line_saldo) over (partition by account_id order by date,transaction_id) as "saldo"
      from account_transactions_with_line_saldo
    SQL
  end

  def down
    execute "drop view account_transactions"
  end
end
