CREATE TABLE symbols(
   symbol VARCHAR(50) ,
   name VARCHAR(256)  NOT NULL,
   currency VARCHAR(50) ,
   active BOOLEAN,
   PRIMARY KEY(symbol)
);

CREATE TABLE accounts(
   account_id VARCHAR(50) ,
   name VARCHAR(50)  NOT NULL,
   created TIMESTAMP NOT NULL,
   currency VARCHAR(50)  NOT NULL,
   balance MONEY NOT NULL,
   status VARCHAR(50)  NOT NULL,
   closed_date TIMESTAMP,
   user_id VARCHAR(256)  NOT NULL,
   PRIMARY KEY(account_id)
);

CREATE TABLE transactions(
   transaction_id VARCHAR(50) ,
   created_at TIMESTAMP NOT NULL,
   amount MONEY NOT NULL,
   status VARCHAR(50)  NOT NULL,
   type VARCHAR(50)  NOT NULL,
   account_id VARCHAR(50)  NOT NULL,
   PRIMARY KEY(transaction_id),
   FOREIGN KEY(account_id) REFERENCES accounts(account_id)
);

CREATE TABLE trends(
   trend_id VARCHAR(50) ,
   entrie TIMESTAMP,
   price MONEY,
   trend VARCHAR(50) ,
   signal VARCHAR(50) ,
   symbol VARCHAR(50)  NOT NULL,
   PRIMARY KEY(trend_id),
   FOREIGN KEY(symbol) REFERENCES symbols(symbol)
);

CREATE TABLE trades(
   trade_id INTEGER GENERATED ALWAYS AS IDENTITY,
   qty NUMERIC(15,2)   NOT NULL,
   entry_date TIMESTAMP NOT NULL,
   status VARCHAR(50)  NOT NULL,
   transaction_id VARCHAR(50)  NOT NULL,
   symbol VARCHAR(50)  NOT NULL,
   PRIMARY KEY(trade_id),
   FOREIGN KEY(transaction_id) REFERENCES transactions(transaction_id),
   FOREIGN KEY(symbol) REFERENCES symbols(symbol)
);
