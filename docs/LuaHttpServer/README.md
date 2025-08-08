# Lua HTTP Server

## REST Endpoints

Query parameter and/or request body is not needed unless specified. A basic HTTP authentication header `Authorization: Basic <token>` is required for all request unless specified otherwise. The `token` can be either hashed with `bcrypt` or a simple `base64` encoding.

By default, the data returned by the endpoints is usually in this format:

```json
{
    "data": {} // Data could be an object or an array of objects.
}
```

For endpoints that do not return any data, a `message` or `status` field will be returned. Any error during the endpoint execution will be returned with `error` field with a related error message.

* [Webserver control](./Webserver.md)
* [Player Management](./PlayerManagement.md)
* [Event management](./EventManagement.md)
* [Vehicle management](./VehicleManagement.md)
* [Properties management](./PropertyManagement.md)
* [Cargo management](./CargoManagement.md)
* [Assets management](./AssetsManagement.md)
* [Moderation tool](./ModerationTools.md)
* [Company management](./CompanyManagement.md)
