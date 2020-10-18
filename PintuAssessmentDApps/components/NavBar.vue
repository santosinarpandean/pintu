<template>
  <v-app id="inspire">
    <v-app-bar app color="blue-grey darken-2" dense dark>
      <v-toolbar-title>DApps Pintu</v-toolbar-title>
      <v-spacer></v-spacer>

      <v-btn
        v-if="!metamaskIsConnected"
        depressed
        color="primary"
        @click="connectMetamask"
      >Connect Metamask</v-btn>

      <v-toolbar-title class="caption ml-3 pl-2">
        <v-icon v-if="metamaskIsConnected" color="green">mdi-square-rounded</v-icon>
        {{ connectedAccount }}
      </v-toolbar-title>
      <v-toolbar-title class="caption ml-3 pl-2">
        {{ ethBalance }}
        <span v-if="metamaskIsConnected">ETH</span>
      </v-toolbar-title>
    </v-app-bar>

    <v-main>
      <!--  -->
    </v-main>
  </v-app>
</template>

<script>
export default {
  async created() {
    if (typeof window.web3.eth.accounts[0] !== "undefined") {
      if (window.web3.version.network !== process.env.ETHEREUM_NETWORK_ID) {
        window.web3 = null;
        return alert(
          `Please connect to ${process.env.ETHEREUM_NETWORK} network`
        );
      }
      this.connectedAccount = window.web3.eth.accounts[0];
      this.metamaskIsConnected = true;

      window.web3.eth.getBalance(window.web3.eth.accounts[0], (error, data) => {
        this.ethBalance = window.web3.fromWei(data.toNumber(), "ether");
      });
    }
  },
  asyncData(context) {},
  data: () => ({
    metamaskIsConnected: false,
    connectedAccount: "",
    connectedNetwork: null,
    ethBalance: null
  }),

  methods: {
    async connectMetamask(context) {
      const ethereum = window.ethereum;
      if (ethereum) {
        window.web3 = new Web3(ethereum);
        try {
          await ethereum.enable();
          if (window.web3.version.network !== process.env.ETHEREUM_NETWORK_ID) {
            return alert(
              `Please connect to ${process.env.ETHEREUM_NETWORK} network`
            );
          }

          location.reload();
          // this.metamaskIsConnected = true;
          // this.connectedAccount = window.web3.eth.accounts[0];

          // window.web3.eth.getBalance(
          //   window.web3.eth.accounts[0],
          //   (error, data) => {
          //     this.ethBalance = window.web3.fromWei(data.toNumber(), "ether");
          //   }
          // );
        } catch (error) {
          // In case user denied the access
          return alert(error.message);
        }
      } else {
        return alert(
          "Metamask is not detected, please install / enable your metamask"
        );
      }
    }
  }
};
</script>
