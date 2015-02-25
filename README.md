# Sneakers

![build status](https://travis-ci.org/everydayhero/sneakers.svg?branch=master)

![Sneakers](http://upload.wikimedia.org/wikipedia/en/a/aa/Sneakersmovie.jpg)

Signing of partial orders.

## How to use

### Generating a Secret

There are three components to a valid signature:

1. Application Name
2. Application Key
3. List of attributes to be signed

Before generating a signature an application needs to be registered:

``` ruby
Sneakers::SignedApplications.register(
  "application_name",
  "application_key",
  %i(
    context
    merchant
    product
    quantity
    amount_discount
    page_id
  ), # signed params
  %i(
    amount
    page_id
    thank_as
    message
    opt_in
  ) # unsigned params
)
```

At the moment the signed parameters are defined by the user setting up the
application, in the future these would be determined by the type of payment
(direct donation, p2p donation etc). The unsigned parameters are information
collected on the form that you want to receive post payment.

From here a signature can be generated:

``` ruby
signature = Sneakers::Signature.sign(
  "application_name",
  "application_key",
  context: "123",
  merchant: "123",
  product: "123",
  quantity: "123",
  amount_discount: "0.00",
  page_id: "123",
)
```

Your signature will be in the format "application_name:encoded_values".
