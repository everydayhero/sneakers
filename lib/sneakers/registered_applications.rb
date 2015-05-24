Sneakers::SignedApplications.register(
  "supporter_donation",
  ENV.fetch("SUPPORTER_DONATION_KEY"),
)

Sneakers::SignedApplications.register(
  "charity_profile_donation",
  ENV.fetch("CHARITY_PROFILE_DONATION_KEY"),
)
