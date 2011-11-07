module ApplicationHelper

  def format_number( number )
    # FixMe: Hardcoded locale
    number_to_currency( number, :unit => '', :locale => 'de-AT' )
  end
end
