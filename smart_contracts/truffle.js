const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = 'provide add price reunion dose hotel bind suffer argue world network tree'

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: function() { 
        return new HDWalletProvider(
          mnemonic,
          'https://rinkeby.infura.io/v3/afe09bdcc9d74acd8fa94e8f992d2e5a'
          )
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
    }
  }
};

