Sneakers::SignedApplications.register(
  ENV.fetch("SUPPORTER_DONATION_PUBLIC_KEY"),
  ENV.fetch("SUPPORTER_DONATION_SECRET_KEY"),
)

Sneakers::SignedApplications.register(
  ENV.fetch("CHARITY_PROFILE_DONATION_PUBLIC_KEY"),
  ENV.fetch("CHARITY_PROFILE_DONATION_SECRET_KEY"),
)
