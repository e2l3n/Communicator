# Communicator Apache Cordova #

Communicator Cordova Plugin, provides ability for hybrid apps to advertise presence over LAN and respond to server sent commands.  

## Platforms supported ##

- [x] iOS v.6.0 or later

## How to use? ##
To install this plugin, follow the [Command-line Interface Guide](http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface).

- <p>Installation<p>
<pre><code>cordova plugin add https://github.com/e2l3n/Communicator.git</code></pre>
- <p>Uninstallation:<p>
<pre><code>cordova plugin rm com.tomapopov.WAUCommunicator</code></pre>


## Javascript API ##

APIs:
```javascript

broadcast(options, success, fail);
listen(options, success, fail);

enableCaching(options, success, fail);

```
Check the javascript interface [Communicator.js](https://github.com/e2l3n/Communicator/blob/master/www/Communicator.js) for more information.

## Example code ##

Check the [Xcode Demo project] (https://github.com/e2l3n/Communicator-DemoApp).
