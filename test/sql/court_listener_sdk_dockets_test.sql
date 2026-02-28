SET datestyle = 'ISO';
SET court_listener_sdk.api_key = 'My API Key';

SELECT *
FROM court_listener_sdk_dockets.retrieve(id := 0);

SELECT *
FROM court_listener_sdk_dockets.list()
LIMIT 42;