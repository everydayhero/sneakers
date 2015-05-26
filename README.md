# Sneakers

![build status](https://travis-ci.org/everydayhero/sneakers.svg?branch=master)

![Sneakers](http://upload.wikimedia.org/wikipedia/en/a/aa/Sneakersmovie.jpg)

Signing of partial orders.

## Supporter Page P2P Donations

```
order = Sneakers::Order.supporter(region_code).order(
  supporter_donation,
  order_id,
  financial_context_id,
  merchant_id,
  timestamp,
  payer,
  amount,
)
order.signature
order.hash #=> {id: order_id, region: region_code ...}
```

## Charity Profile Direct Donations

```
order = Sneakers::Order.charity_profile(region_code).order(
  charity_profile_donation,
  order_id,
  financial_context_id,
  merchant_id,
  timestamp,
  payer,
  amount,
)
order.signature
order.hash #=> {id: order_id, region: region_code ...}
```
