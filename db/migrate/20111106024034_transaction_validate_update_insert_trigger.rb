class TransactionValidateUpdateInsertTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function transaction_validate_on_update_insert()
        returns trigger as $F$
      begin
        if NEW.debit_account_id IS NOT DISTINCT FROM NEW.credit_account_id then
          raise exception $$Debit and credit accounts cannot be identical.$$;
        end if;
        return NEW;
      end
      $F$ language plpgsql;

      create trigger transaction_validate_on_update_insert_trigger
        before insert or update
        on transactions
        for each row
        execute procedure transaction_validate_on_update_insert();
    SQL
  end

  def down
  end
end
