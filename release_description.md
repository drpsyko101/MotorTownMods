### New endpoints!

* `GET /companies/*/depots` - List the company-owned depots
* `GET /companies/*/depots/*` - List specific company-owned depot
* `GET /delivery` - List currently active deliveries
* `GET /delivery/*` - List specific active delivery
* `DELETE /players/*/gameplay/effects` - Delete active gameplay effect on selected player

### New webhooks

* `ServerCreateCompany`
* `ServerCloseDownCompany`
* `ServerRequestJoinCompany`
* `ServerDenyCompanyJoinRequest`

### Bugfixes

* Fix `GET /companies` will return just companies, instead of needing to specify the filter
* Fix `POST /players/<id>/teleport` not actually teleport player
* Fix `ServerCargoArrived` returning empty cargo list
