# REST API Reference

This document lists all API methods, and details the authentication mechanism. Unless you're writing a library you may wish to consult the <a href="/docs/server_api_guide">server API overview</a> instead.
{: class="intro"}

* **[General](#general)**
* **[Events](#events)**
  * [Trigger an Event](#method-post-event)
* **[Channels](#channels)**
  * [Fetch info for multiple channels](#method-get-channels)
  * [Fetch info for one channel](#method-get-channel)
* **[Users](#users)**
  * [Fetch users from presence channel](#method-get-users)
* **[Authentication](#authentication)**
{: class="toc"}

## General
{: id="general"}

The API is hosted at <http://api.pusherapp.com>, and may be accessed via HTTP or HTTPS.

All requests MUST be authenticated, as described [below](#auth-signature).

Parameters MUST be submitted in the query string for GET requests. For POST requests, parameters MAY be submitted in the query string, but SHOULD be submitted in the POST body as a JSON hash (while setting `Content-Type: application/json`).

HTTP status codes are used to indicate the success or otherwise of requests. The following status are common:

<%= build_table(%w{Code Description}, {
  "200" => "Successful request. Body will contain a JSON hash of response data",
  "400" => "Error: details in response body",
  "401" => "Authentication error: response body will contain an explanation",
  "403" => "Forbidden: app disabled or over message quota",
}) %>

Other status codes are documented under the appropriate APIs.

----

## Events
{: id="events"}

An event consists of a name and data (typically JSON) which may be sent to all subscribers to a particular channel or channels. This is conventionally known as triggering an event.

### POST event (trigger an event)
{: id="method-post-event"}

    POST /apps/[app_id]/events

Triggers an event on one or more channels.

The event data should not be larger than 10KB. If you attempt to POST an event with a larger data parameter you will receive a 413 error code. If you have a use case which requires a larger messages size please [get in touch](/support).

<div class="notice alert-message block-message info"><p><strong>Note:</strong> a previous version of this resource is now considered deprecated but is detailed <a href="/docs/rest_api_deprecated#method-post-event">here</a>.</p></div>

<div class="notice alert-message block-message info"><p>
  <strong>Note:</strong>
  For POST requests we recommend including parameters in the JSON body. If using the query string, arrays should be sent as channels[]=channel1&amp;channels[]=channel2; this is more verbose than the JSON representation.
</p></div>

#### Request

<%= build_table(%w{Parameter Description}, {
  name: 'Event name (required)',
  data: 'Event data (required) - limited to 10KB',
  channels: 'Array of one or more channel names - limited to 10 channels',
  channel: 'Channel name if publishing to a single channel (can be used instead of channels)',
  socket_id: 'Excludes the event from being sent to a specific connection (see <a href="/docs/server_api_guide/server_excluding_recipients">excluding recipients</a>)'.html_safe
}) %>

#### Successful response

The event has been received and will be send asynchronously to all sockets. Response is an empty JSON hash.

----

## Channels
{: id="channels"}

Channels are identified by name and are used to determine which messages are delivered to which clients. Security may be added by using private or presence channels (identified by name prefix). Channels are created and destroyed automatically whenever clients subscribe or unsubscribe.

### GET channels (fetch info for multiple channels)
{: id="method-get-channels"}

    GET /apps/[app_id]/channels

Allows fetching a hash of occupied channels (optionally filtered by prefix), and optionally one or more attributes for each channel.

#### Request

<%= build_table(%w{Parameter Description}, {
  filter_by_prefix: 'Filter the returned channels by a specific prefix. For example in order to return only presence channels you would set <code>filter_by_prefix=presence-</code>'.html_safe,
  info: 'A comma separated list of attributes which should be returned for each channel. If this parameter is missing, an empty hash of attributes will be returned for each channel.'.html_safe
}) %>

##### Available info attributes

<%= build_table(["Attribute", "Type", "Applicable channels", "Description"], [
  ["user_count", "Integer", "Presence", "Number of <strong>distinct</strong> users currently subscribed to this channel (a single user may be subscribed many times, but will only count as one)".html_safe]
]) %>

If an attribute such as `user_count` is requested, and the request is not limited to presence channels, the API will return an error (400 code).

#### Successful response

Returns a hash of channels mapping from channel name to a hash of attributes for that channel (maybe empty)

    {
      "channels": {
        "presence-foobar": {
          user_count: 42
        },
        "presence-another": {
          user_count: 123
        }
      }
    }

----

### GET channel (fetch info for one channel)
{: id="method-get-channel"}

    GET /apps/[app_id]/channels/[channel_name]

Fetch one or some attributes for a given channel.

#### Request

<%= build_table(%w{Parameter Description}, {
  info: 'A comma separated list of attributes which should be returned for the channel. See the table below for a list of available attributes, and for which channel types.'
}) %>

##### Available info attributes

<%= build_table(["Attribute", "Type", "Applicable channels", "Description"], [
  ["user_count", "Integer", "Presence", "Number of <strong>distinct users</strong> currently subscribed to this channel (a single user may be subscribed many times, but will only count as one)".html_safe],
  ["subscription_count", "Integer", "All", "[BETA] Number of <strong>connections</strong> currently subscribed to this channel. This attribute is not available by default; please contact support@pusher.com if you would like to beta test this feature.".html_safe]
]) %>

Requesting an attribute which is not available for the requested channel will return an error (for example requesting a the `user_count` for a public channel).

#### Successful response

Returns a hash describing the state of the channel. The occupied status is always reported, as well as any requested attributes.

    {
      occupied: true,
      user_count: 42,
      subscription_count: 42
    }

----

## Users
{: id="users"}

### GET users
{: id="method-get-users"}

    GET /apps/[app_id]/channels/[channel_name]/users

Fetch user ids currently subscribed to a presence channel. This functionality is primarily aimed to complement [presence webhooks](<%= docs_webhooks_path %>#presence), by allowing the initial state of a channel to be fetched.

Note that only `presence channels` allow this functionality, and a request to any other kind of channel will result in a 400 HTTP code.

#### Request

No additional parameters needed or allowed.

#### Successful response

Returns an array of subscribed users ids

    {
      "users": [
        { "id": 1 },
        { "id": 2 }
      ]
    }

----

## HTTP Keep-Alive
{: id="keepalive"}

The Pusher API supports
[HTTP Keep-Alive](https://en.wikipedia.org/wiki/HTTP_persistent_connection).
HTTP client libraries that implement this feature are able to re-use a
single TCP connection to send multiple HTTP requests thus avoiding the
overhead of the TCP connection (typically 100-200ms) between each subsequent request.

In scenarios where many requests are sent at the same time this can improve
the throughput and decrease the load on the machine that is sending those
requests.

## Authentication
{: id="authentication"}

The following query parameters must be included with all requests, and are used to authenticate the request

<%= build_table([], {
  auth_key: "Your application key",
  auth_timestamp: "The number of seconds since January 1, 1970 00:00:00 GMT. The server will only accept requests where the timestamp is within 600s of the current time",
  auth_version: "Authentication version, currently 1.0",
  body_md5: "If the request body is nonempty (for example for POST requests to `/events`), this parameter must contain the hexadecimal MD5 hash of the body",
}) %>

Once all the above parameters have been added to the request, a signature is calculated

<%= build_table([], {
  auth_signature: "Authentication signature, described below",
}) %>

### Generating authentication signatures
{: id="auth-signature"}

The signature is a HMAC SHA256 hex digest. This is generated by signing a string made up of the following components concatenated with newline characters `\n`.

* The uppercase request method (e.g. `POST`)
* The request path (e.g. `/some/resource`)
* The query parameters sorted by key, with keys converted to lowercase, then joined as in the query string. Note that the string must not be url escaped (e.g. given the keys `auth_key`: `foo`, `Name`: `Something else`, you get `auth_key=foo&name=Something else`)

See below for a worked example.

### Worked authentication example

Assume that we wish to trigger the `foo` event on the `project-3` channel with JSON `{"some":"data"}` and that our app credentials are

    app_id  3
    key     278d425bdf160c739803
    secret  7ad3773142a6692b25b8

The request url is

    http://api.pusherapp.com/apps/3/events

Since this is a POST request, the body should contain a hash of parameters encoded as JSON where the data parameter is itself JSON encoded:

    {"name":"foo","channels":["project-3"],"data":"{\"some\":\"data\"}"}

Note that these parameters may be provided in the query string, although this is discouraged.

Authentication parameters should be added (assume that these are included in the query string, so the body is unchanged from above). Since the body is non-empty a body_md5 parameter should be added

    auth_key        278d425bdf160c739803
    auth_timestamp  1353088179
    auth_version    1.0
    body_md5        ec365a775a4cd0599faeb73354201b6f

The signature is generated by signing the following string
    POST\n/apps/3/events\nauth_key=278d425bdf160c739803&auth_timestamp=1353088179&auth_version=1.0&body_md5=ec365a775a4cd0599faeb73354201b6f

This should be signed by generating the HMAC SHA256 hex digest with secret key `7ad3773142a6692b25b8`. This yields the following signature

    da454824c97ba181a32ccc17a72625ba02771f50b50e1e7430e47a1f3f457e6c

The api request then becomes

    POST /apps/3/events?auth_key=278d425bdf160c739803&auth_timestamp=1353088179&auth_version=1.0&body_md5=ec365a775a4cd0599faeb73354201b6f&auth_signature=da454824c97ba181a32ccc17a72625ba02771f50b50e1e7430e47a1f3f457e6c HTTP/1.1
    Content-Type: application/json

    {"name":"foo","channels":["project-3"],"data":"{\"some\":\"data\"}"}

Or using curl:

    $ curl -H "Content-Type: application/json" -d '{"name":"foo","channels":["project-3"],"data":"{\"some\":\"data\"}"}' "http://api.pusherapp.com/apps/3/events?auth_key=278d425bdf160c739803&auth_timestamp=1353088179&auth_version=1.0&body_md5=ec365a775a4cd0599faeb73354201b6f&auth_signature=da454824c97ba181a32ccc17a72625ba02771f50b50e1e7430e47a1f3f457e6c"
    {}

If you're having difficulty generating the correct signature in your library please take a look at this [example](http://gist.github.com/376898) [gist].
