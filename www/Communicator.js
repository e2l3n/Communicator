var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');

var communicatorExport = {};


// CONSTANTS
/**
 * This enum represents Communicator's supported command types.  
 *	Use one of these constants as the commandType when calling function createBannerView(args) {
 	
 }
 .
 * @const
 */
communicatorExport.COMMAND_TYPE = {
    kCOMMAND_BROADCASTSTART : 'WAUBroadcastStart',
    kCOMMAND_BROADCASTSTOP : 'WAUBroadcastStop',
    kCOMMAND_LISTENSTART : 'WAUListenStart',
    kCOMMAND_LISTENSTOP : 'WAUListenStop',
	kOMMAND_CACHEENABLE : 'WAUCacheEnable',
    kCOMMAND_CACHEDISABLE : 'WAUCacheDisable',
};

/*
 * Broadcast presence. 
 * 
 * @param {string} use kCOMMAND_BROADCASTSTART to start broacasting or kCOMMAND_BROADCASTSTOP to stop.  
 * @param {function()} successCallback The function to call if the requested action has been
	successfully executed.
 * @param {function()} failureCallback The function to call if the requested action has failed.
 */

communicatorExport.broadcast = 
function (commandType ,successCallback, errorCallback) {
  	cordova.exec(
		successCallback, 
		errorCallback, 
		"WAUCommunicator", 
		"broadcast", 
		[commandType]);
};

/*
 * Listen for socket connections. 
 * 
 * @param {string} use kCOMMAND_LISTENSTART to start listening for socket connections or kCOMMAND_LISTENSTOP to stop.  
 * @param {function()} successCallback The function to call if the requested action has been
	successfully executed.
 * @param {function()} failureCallback The function to call if the requested action has failed.
 */

communicatorExport.listen = 
function (commandType, successCallback, errorCallback) {
  cordova.exec(
	  successCallback, 
	  errorCallback, 
	  "WAUCommunicator", 
	  "listen", 
	  [commandType]);
};

/*
 * Enables or disables caching of data. 
 * 
 * @param {string} use kCommand_CacheEnable to enable caching or kCOMMAND_LISTENSTOP to 
 * disable caching/and perform cache clean up/.  
 * @param {function()} successCallback The function to call if the requested action has been
	successfully executed.
 * @param {function()} failureCallback The function to call if the requested action has failed.
 */

communicatorExport.enableCaching = 
function (commandType, successCallback, errorCallback) {
  cordova.exec(
	  successCallback, 
	  errorCallback, 
	  "WAUCommunicator", 
	  "enableCaching", 
	  [commandType]);
};


module.exports = communicatorExport;