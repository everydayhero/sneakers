Sneakers::SignedApplications.register(
  "supporter_donation",
  ENV.fetch("SUPPORTER_DONATION_KEY"),
  %w(
    context
    merchant
    product
    quantity
    amount_discount
    page_id
  ),
  %w(
    amount_gross
    payer
    donor
    thank_as
    message
    opt_in
  ),
)

Sneakers::SignedApplications.register(
  "charity_profile_donation",
  ENV.fetch("CHARITY_PROFILE_DONATION_KEY"),
  %w(
    context
    merchant
    product
    quantity
    amount_discount
  ),
  %w(
    amount_gross
    payer
    donor
  ),
)
