# generate_uid_50
## Description

Generates a pseudo-random 50-character identifier used for internal IDs such as transactions and accounts.

## Inputs
- None
## Verifications
- Uses randomness (random())
- Uses timestamp (clock_timestamp())
- Ensures uniqueness by hashing input combination

# transaction_share_buy
## Description

Executes a share purchase:

Deducts funds from account
Creates a transaction record
Creates a trade entry linked to the transaction
## Inputs
- p_account_id: account performing the purchase
- p_symbol: asset symbol being bought
- p_total: total cost of the trade
- p_qty: quantity of shares purchased

## Verifications
- Account must exist
- Account must be OPEN
- Account must have sufficient balance (balance >= p_total)
- Rejects if insufficient funds or account not found
- Implicitly assumes symbol is valid (no validation inside function)

# transaction_share_sell
## Description

Executes a share sale:

Marks a trade as sold
Calculates profit based on price × quantity
Updates account balance
Creates a transaction record

## Inputs
- p_account_id: account receiving funds
- p_trade_id: trade being sold
- p_price: sell price per unit

## Verifications
- Trade must exist
- Trade must be in ACTIVE state
- Rejects if trade already marked as sold
- Account must exist and be OPEN
- Ensures trade is not double-sold

# transaction_account
## Description

Transfers money between two accounts:

Debits sender
Credits receiver
Logs both sides as transactions

## Inputs
- p_account_id: sender account
- p_account_id1: receiver account
- p_total: transfer amount

## Verifications
- Sender account must exist
- Sender must be OPEN
- Sender must have sufficient funds
- Receiver account must exist
- Receiver must be OPEN
- Rejects insufficient funds or missing accounts

# open_account
## Description

Creates a new account with initial zero balance.

## Inputs
- p_name: account holder name
- p_currency: account currency
- p_user_id: user owning the account

## Verifications
- No explicit validation inside function
- Assumes user ID is valid
- Assumes currency is valid
- Generates unique account ID internally

# close_account
## Description

Closes an existing account if it is currently active.

## Inputs
- p_account_id: account to close
- Verifications
- Account must exist
- Account must be in OPEN state
- Prevents closing already closed accounts
- Raises error if account is missing or already closed

# disable_symbols
## Description

Disables trading for a symbol if no active trades remain.

## Inputs
- p_symbol: symbol to disable

## Verifications
- Ensures no trades exist with status other than SOLD
- Prevents disabling symbols with open positions
- Symbol must exist in symbols table
- Ensures safe deactivation for active markets