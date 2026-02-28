SET datestyle = 'ISO';
SET court_listener_sdk.api_key = 'My API Key';

SELECT *
FROM court_listener_sdk_courts.retrieve(id := 'id');

SELECT *
FROM court_listener_sdk_courts.list()
LIMIT 42;