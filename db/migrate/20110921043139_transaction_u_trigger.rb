class TransactionUiTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function check_update_allowed()
        returns trigger as $F$
      begin
        if OLD.locked then
          raise exception $$This record is locked and does not allow updating of certain fields.$$;
        else
          return NEW;
        end if;
      end
      $F$ language plpgsql;

      create trigger check_update_allowed_u_trigger
        before update
        on transactions
        for each row
        execute procedure check_update_allowed();
    SQL
  end

  def down
  end
end
