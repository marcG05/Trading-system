import yfinance as yf
import pandas as pd

def fetch_market_snapshot(symbols):
    """
    Fetches the current market data for a list of stock/crypto symbols
    and returns a Pandas DataFrame.
    """
    print(f"Fetching market data for {len(symbols)} symbols...")
    market_data = []

    for symbol in symbols:
        try:
            # Create a Ticker object for the symbol
            ticker = yf.Ticker(symbol)
            
            # .fast_info is a lightweight way to get current/last day quotes
            info = ticker.fast_info
            
            # Append the data to our list as a dictionary
            market_data.append({
                "Symbol": symbol,
                "Last Price": round(info.last_price, 2),
                "Prev Close": round(info.previous_close, 2),
                "Open": round(info.open, 2),
                "Day High": round(info.day_high, 2),
                "Day Low": round(info.day_low, 2),
                "Volume": int(info.last_volume)
            })
            
        except Exception as e:
            print(f"⚠️ Warning: Could not fetch data for {symbol}. It may be delisted or invalid.")

    # Convert the list of dictionaries into a Pandas DataFrame
    df = pd.DataFrame(market_data)
    
    # Set the Symbol column as the index for a cleaner look
    if not df.empty:
        df.set_index("Symbol", inplace=True)
        
    return df

# ==========================================
# Example Usage
# ==========================================
if __name__ == "__main__":
    # Define your list of symbols (Stocks, ETFs, or Crypto)
    # E.g., AAPL (Apple), MSFT (Microsoft), BTC-USD (Bitcoin)
    my_symbols = ['AAPL', 'MSFT', 'NVDA', 'SPY', 'BTC-USD']
    
    # Fetch the data
    df_market = fetch_market_snapshot(my_symbols)
    
    # Display the resulting data frame
    print("\n--- Current Market Data Frame ---")
    print(df_market.to_string())