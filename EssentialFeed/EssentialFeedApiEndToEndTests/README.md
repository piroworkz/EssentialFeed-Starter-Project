# EssentialFeedApiEndToEndTests

## Purpose
This target performs end-to-end verification against the public Essential Developer test API, validating that remote responses still match the contract expected by the app.

## Architecture
Tests spin up real instances of `URLSessionHTTPClient`, `RemoteFeedLoader`, and `RemoteFeedImageDataLoader` from the production module. They exercise the HTTP stack without mocks, asserting that item payloads and image data match the fixed dataset served by the backend.

## Key scenarios
- `test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData`: confirms the JSON feed returns eight predefined items.
- `test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData`: verifies the sample image endpoint delivers non-empty binary data.

## Usage
Because these tests hit the network, run them sparingly with `xcodebuild -scheme EssentialFeed -only-testing:EssentialFeedApiEndToEndTests test`. Use the suite to detect contract regressions after backend changes or when upgrading networking code.
