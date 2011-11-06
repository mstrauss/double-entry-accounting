class TransactionValidateUpdateTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function transaction_validate_on_update()
        returns trigger as $F$
      begin
        if NEW.debit_account_id IS NOT DISTINCT FROM NEW.credit_account_id then
          raise exception $$Debit and credit accounts cannot be identical.$$;
        end if;
        if OLD.reconciled = true then
          if NEW.reconciled = false then
            raise exception $$It is not possible to unreconcile a transaction after it has been reconciled.$$;
          elsif OLD.debit_account_id IS DISTINCT FROM NEW.debit_account_id then
            raise exception $$This record is reconciled and does not allow updating 'debit_account_id'.$$;
          elsif OLD.credit_account_id IS DISTINCT FROM NEW.credit_account_id then
            raise exception $$This record is reconciled and does not allow updating 'credit_account_id'.$$;
          elsif OLD.amount IS DISTINCT FROM NEW.amount then
            raise exception $$This record is reconciled and does not allow updating 'amount'.$$;
          elsif OLD.reconciled IS DISTINCT FROM NEW.reconciled then
            raise exception $$This record is reconciled and does not allow updating 'reconciled'.$$;
          elsif OLD.date IS DISTINCT FROM NEW.date then
            raise exception $$This record is reconciled and does not allow updating 'date'.$$;
          elsif OLD.text IS DISTINCT FROM NEW.text then
            raise exception $$This record is reconciled and does not allow updating 'text'.$$;
          end if;
        end if;
        if OLD.locked = true then
          if OLD.debit_account_id IS DISTINCT FROM NEW.debit_account_id then
            raise exception $$This record is locked and does not allow updating 'debit_account_id'.$$;
          elsif OLD.credit_account_id IS DISTINCT FROM NEW.credit_account_id then
            raise exception $$This record is locked and does not allow updating 'credit_account_id'.$$;
          elsif OLD.amount IS DISTINCT FROM NEW.amount then
            raise exception $$This record is locked and does not allow updating 'amount'.$$;
          elsif OLD.reconciled IS DISTINCT FROM NEW.reconciled then
            raise exception $$This record is locked and does not allow updating 'reconciled'.$$;
          elsif OLD.date IS DISTINCT FROM NEW.date then
            raise exception $$This record is locked and does not allow updating 'date'.$$;
          elsif OLD.text IS DISTINCT FROM NEW.text then
            raise exception $$This record is locked and does not allow updating 'text'.$$;
          elsif OLD.notes IS DISTINCT FROM NEW.notes then
            raise exception $$This record is locked and does not allow updating 'notes'.$$;
          end if;
        end if;
        return NEW;
      end
      $F$ language plpgsql;

      create trigger transaction_validate_u_trigger
        before update
        on transactions
        for each row
        execute procedure transaction_validate_on_update();
    SQL
  end

  def down
  end
end
