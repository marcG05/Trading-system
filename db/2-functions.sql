CREATE OR REPLACE FUNCTION generate_uid_50()
RETURNS varchar
LANGUAGE sql
AS $$
  SELECT substr(md5(random()::text || clock_timestamp()::text), 1, 50);
$$;

CREATE OR REPLACE FUNCTION transaction_share_buy(
    p_account_id varchar,
    p_symbol varchar,
    p_total money,
    p_qty numeric
)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    trans_id varchar;
BEGIN

    UPDATE accounts
    SET balance = balance - p_total
    WHERE account_id = p_account_id
    AND balance >= p_total AND status = 'OPEN';

    IF NOT FOUND THEN
        IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id) THEN
            RAISE EXCEPTION 'Account not found';
        ELSE
            RAISE EXCEPTION 'Insufficient funds';
        END IF;
    END IF;
    -- generate transaction id
    trans_id := generate_uid_50();
    -- insert transaction
    INSERT INTO transactions(
        transaction_id,
        created_at,
        amount,
        status,
        type,
        account_id
    )
    VALUES (
        trans_id,
        now(),
        0 - p_total,
        'FILLED',
        'TRADE-BUY',
        p_account_id
    );

    -- insert trade
    INSERT INTO trades(
        qty,
        entry_date,
        status,
        transaction_id,
        symbol
    )
    VALUES (
        p_qty,
        now(),
        'CREATED',
        trans_id,
        p_symbol
    );
    -- return transaction id
    RETURN trans_id;
END;
$$;

CREATE OR REPLACE FUNCTION transaction_share_sell(
    p_account_id varchar,
    p_trade_id integer,
    p_price money
)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    trans_id varchar;
BEGIN

    UPDATE trades
    set status = 'SOLD'
    where trade_id = p_trade_id and status = 'ACTIVE';

    IF NOT FOUND THEN
        IF NOT EXISTS (SELECT 1 FROM trades WHERE trade_id = p_trade_id) THEN
            RAISE EXCEPTION 'Trade not found';
        ELSE
            RAISE EXCEPTION 'Trade already sold';
        END IF;
    END IF;
    -- generate transaction id
    trans_id := generate_uid_50();
    -- insert transaction
    INSERT INTO transactions(
        transaction_id,
        created_at,
        amount,
        status,
        type,
        account_id
    )
    VALUES (
        trans_id,
        now(),
        p_price* (select qty from trades where trade_id = p_trade_id),
        'FILLED',
        'TRADE-SELL',
        p_account_id
    );

    UPDATE accounts SET
    balance = balance + (p_price * (select qty from trades where trade_id = p_trade_id))
    WHERE account_id = p_account_id AND status = 'OPEN';

    IF NOT FOUND THEN
        IF NOT EXISTS (SELECT 1 FROM trades WHERE trade_id = p_trade_id) THEN
            RAISE EXCEPTION 'Account not found';

        END IF;
    END IF;
    -- return transaction id
    RETURN trans_id;
END;
$$;

CREATE OR REPLACE FUNCTION transaction_account(
    p_account_id varchar,
    p_account_id1 varchar,
    p_total money
)
RETURNS TABLE (upcoming varchar, incoming varchar)
LANGUAGE plpgsql
AS $$
DECLARE
    trans_id varchar;
    trans_id1 varchar;
BEGIN

    UPDATE accounts
    SET balance = balance - p_total
    WHERE account_id = p_account_id
    AND balance >= p_total AND status = 'OPEN';

    IF NOT FOUND THEN
        IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id) THEN
            RAISE EXCEPTION 'Account not found';
        ELSE
            RAISE EXCEPTION 'Insufficient funds';
        END IF;
    END IF;

    UPDATE accounts
    SET balance = balance + p_total
    WHERE account_id = p_account_id1 AND status = 'OPEN';

    IF NOT FOUND THEN
        IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id1) THEN
            RAISE EXCEPTION 'Account not found';
        END IF;
    END IF;
    -- generate transaction id
    trans_id := generate_uid_50();
    -- insert transaction
    INSERT INTO transactions(
        transaction_id,
        created_at,
        amount,
        status,
        type,
        account_id
    )
    VALUES (
        trans_id,
        now(),
        0 - p_total,
        'FILLED',
        'ACCOUNT-UPCOMING',
        p_account_id
    );

    trans_id1 := generate_uid_50();
    -- insert transaction
    INSERT INTO transactions(
        transaction_id,
        created_at,
        amount,
        status,
        type,
        account_id
    )
    VALUES (
        trans_id1,
        now(),
        p_total,
        'FILLED',
        'ACCOUNT-INCOMING',
        p_account_id1
    );
    -- return transaction id
    RETURN QUERY
    SELECT trans_id, trans_id1;
END;
$$;

CREATE OR REPLACE FUNCTION open_account(p_name varchar, p_currency varchar, p_user_id varchar)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    account varchar;
BEGIN
    account := generate_uid_50()
    INSERT INTO accounts (account_id, name, created, currency, balance, status, user_id) VALUES (account, p_name, now(), p_currency, 0, 'OPEN', p_user_id);
    RETURN account;
END;
$$;

CREATE OR REPLACE FUNCTION close_account(p_account_id varchar)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE accounts
    SET status = 'CLOSED'
    WHERE account_id = p_account_id
    AND status = 'OPEN';

    IF NOT FOUND THEN
        IF NOT EXISTS (
            SELECT 1 FROM accounts WHERE account_id = p_account_id
        ) THEN
            RAISE EXCEPTION 'Account not found';
        ELSE
            RAISE EXCEPTION 'Account already closed';
        END IF;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION disable_symbols(p_symbol varchar)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM trades
        WHERE symbol = p_symbol
        AND status <> 'SOLD'
    ) THEN
        RAISE EXCEPTION 'Cannot disable symbol: open trades still exist';
    END IF;

    UPDATE symbols
    SET active = FALSE
    WHERE symbol = p_symbol;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Symbol not found';
    END IF;

END;
$$;