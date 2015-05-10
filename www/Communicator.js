function Communicator() {
}

Communicator.prototype.startAdvertisement = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "CDVCommunicator", "Not defined", []);
};

Communicator.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.communicator = new Communicator();

  return window.plugins.communicator;
};

cordova.addConstructor(Communicator.install);
