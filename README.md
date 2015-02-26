# Sneakers

![build status](https://travis-ci.org/everydayhero/sneakers.svg?branch=master)

![Sneakers](http://upload.wikimedia.org/wikipedia/en/a/aa/Sneakersmovie.jpg)

Signing of partial orders.

## Supporter Page P2P Donations

```
order = Sneakers::Order.supporter_donation(
  donation_id,
  region_code,
  financial_context_id,
  merchant_id,
  page_id,
  timestamp,
)
order.signature
order.hash #=> {id: donation_id, region: region_code ...}
```

## Charity Profile Direct Donations

```
order = Sneakers::Order.charity_profile_donation(
  donation_id,
  region_code,
  financial_context_id,
  merchant_id,
  timestamp,
)
order.signature
order.hash #=> {id: donation_id, region: region_code ...}
```
