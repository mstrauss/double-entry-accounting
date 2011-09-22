class TransactionUpdateTimestampsUiTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function transaction_update_timestamps()
        returns trigger as $F$
      begin
        -- update
        if OLD != NULL then
          if OLD.reconciled = false and NEW.reconciled = true then
            NEW.locked := true;
          end if;
          if OLD.locked = true then
            -- unlocking record
            if NEW.locked = false then
              NEW.locked_at := _null_;
            end if;
          else
            -- locking record
            if NEW.locked = true then
              NEW.locked_at := current_timestamp;
            end if;
          end if;
        else
          -- insert
          if NEW.reconciled then
            NEW.reconciled_at := current_timestamp;
            NEW.locked := true;
          end if;
          if NEW.locked then
            NEW.locked_at := current_timestamp;
          end if;
        end if;
        return NEW;
      end
      $F$ language plpgsql;

      create trigger transaction_update_timestamps_ui_trigger
        before insert or update
        on transactions
        for each row
        execute procedure transaction_update_timestamps();
    SQL
  end

  def down
  end
end
