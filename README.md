# Real-Time Price Tracker

iOS app that shows live price updates for 25 stock symbols using a WebSocket echo server.

Built with Xcode 26.1, iOS 16.0+, Swift 6 (strict concurrency).

iOS 16.0 is the minimum possible target — `NavigationStack` (required by the task) was introduced in iOS 16. The lower the deployment target, the wider the user reach.

## How it works

`StockPriceGenerator` sends random prices every 2s to `wss://ws.postman-echo.com/raw`. The echo server returns the same JSON. `WebSocketService` decodes it and publishes via Combine. The ViewModel picks it up and updates the UI.

Both screens (feed and detail) share the same ViewModel — one WebSocket connection, no duplicates.

## Project structure

```
Models/          StockSymbol, StockPriceMessage, ServiceConnectionState
Services/        WebSocketService (actor), StockPriceGenerator (actor)
Screens/
  StockFeed/     Feed list, row view, ViewModel
  StockDetail/   Detail screen
Helpers/         StockSymbol UI extensions
```

## Design decisions

Services are Swift actors — thread safety without locks, works naturally with Swift 6 concurrency.

Connection state comes from `URLSessionWebSocketDelegate`, not manual tracking. This way we know the actual state, not what we hoped for.

The ViewModel uses three data structures instead of a plain `[StockSymbol]` array:

- `tickersDictionary` (`[String: StockSymbol]`) — O(1) lookup and update by ticker
- `sortedTickers` (`[String]`) — lightweight sorted array for the UI
- `tickerIndexMap` (`[String: Int]`) — reverse index: ticker → position in sorted array

❌ With a single `[StockSymbol]` array, each price update would be:

1. `firstIndex(where:)` to find the symbol — O(n)
2. Mutate the element — triggers copy-on-write on the whole array
3. `sort()` the entire array — O(n log n)

Total: **O(n log n)** per update.

✅ With the current approach, each price update is:

1. Update in dictionary — O(1)
2. Find current position via index map — O(1)
3. Binary search for new position — O(log n)
4. Move the ticker string (not the full struct) — O(k), k = shift distance
5. Update index map for affected range — O(k)

Total: **~O(log n)** per update on average.

For 25 symbols this is admittedly overkill, but it's a scalable solution that stays CPU-efficient with thousands or tens of thousands of symbols.

Prices use `Decimal` instead of `Double` — no floating-point artifacts. Formatted string is computed once on update and stored, not recalculated on every redraw.

`FeedState` enum (disconnected/connecting/connected) instead of boolean flags — no invalid state combinations.

Transport model (`StockPriceMessage`, Codable) is separate from domain model (`StockSymbol`) — services don't know about UI concerns.

All services have protocols, so tests use mocks without touching real WebSocket or timers.

## Bonus features

- Price flash animation — row badge highlights green/red on price change, fades out after 1s
- Deep link — `stocks://symbol/{TICKER}` opens the detail screen directly
- Light/dark theme — uses system colors throughout, works in both modes
- Unit tests — StockSymbol, StockFeedViewModel, StockPriceGenerator covered with mocks and expectations
