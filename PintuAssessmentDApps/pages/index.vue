<template>
  <v-main v-if="metamaskIsConnected">
    <br />
    <div style="padding: 0px 30px;">
      <v-card class="mx-auto" max-width="auto" outlined>
        <v-list-item three-line>
          <v-list-item-content>
            <div class="overline mb-4">
              <b>Contract Details</b>
            </div>
            <v-list-item-title class="mb-1">Contract Address: {{ contractAddress }}</v-list-item-title>
            <v-list-item-title class="mb-1">Contract's Network: {{ contractNetwork }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-card>

      <br />
      <v-divider class="mt-4"></v-divider>
      <br />
      <v-card class="mx-auto" max-width="auto" outlined>
        <v-list-item three-line>
          <v-list-item-content>
            <v-list-item-title class="mb-1">
              <p>
                Current Counter Value:
                <span v-if="!errContractCounter">{{contractCounter}}</span>
                <span v-else>{{errContractCounter}}</span>
              </p>
              <p>
                My Deposits Balance:
                <span v-if="!errAccountBalance">{{accountBalance}} ETH</span>
                <span v-else>{{errAccountBalance}}</span>
              </p>
            </v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-card>

      <br />

      <v-row>
        <v-col cols="6">
          <v-btn
            class="ma-2"
            :loading="loadingCounter"
            :disabled="loadingCounter"
            @click="incrementCounter"
          >Increase Counter +1</v-btn>

          <p v-if="txCounterIncrement">
            Counter Increment's Transaction ID:
            <a
              :href="`${urlExplorer}/tx/${txCounterIncrement}`"
              target="_blank"
            >{{txCounterIncrement}}</a>
          </p>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="6">
          <v-text-field
            v-model="depositAmount"
            :rules="depositAmountRules"
            label="Deposit amount (minimal 1 Ether)"
            type="number"
            required
          ></v-text-field>
        </v-col>
        <v-col cols="6">
          <v-btn class="ma-2" :loading="loading" :disabled="loading" @click="deposit">Deposit</v-btn>
        </v-col>
        <br />
        <p v-if="txDeposit">
          Deposit's Transaction ID:
          <a
            :href="`${urlExplorer}/tx/${txDeposit}`"
            target="_blank"
          >{{txDeposit}}</a>
        </p>
      </v-row>

      <v-row>
        <v-col cols="6">
          <v-text-field
            v-model="withdrawalAmount"
            :rules="withdrawalAmountRules"
            label="Withdrawal amount (minimal 1 Ether)"
            type="number"
            required
          ></v-text-field>
        </v-col>
        <v-col cols="6">
          <v-btn
            class="ma-2"
            :loading="loadingWithdrawal"
            :disabled="loadingWithdrawal"
            @click="withdrawal"
          >Withdraw</v-btn>
        </v-col>
        <br />
        <p v-if="txWithdrawal">
          Withdrawal's Transaction ID:
          <a
            :href="`${urlExplorer}/tx/${txWithdrawal}`"
            target="_blank"
          >{{txWithdrawal}}</a>
        </p>
      </v-row>
    </div>
  </v-main>
</template>

<script>
import abi from "../abi";
export default {
  async created() {
    if (typeof window.web3.eth.accounts[0] !== "undefined") {
      if (window.web3.version.network !== process.env.ETHEREUM_NETWORK_ID) {
        return (window.web3 = null);
      }
      this.connectedAccount = window.web3.eth.accounts[0];
      this.metamaskIsConnected = true;

      window.web3.eth.getBalance(window.web3.eth.accounts[0], (error, data) => {
        console.log(data.toNumber());
      });

      const pintuContract = window.web3.eth.contract(abi);
      const pintuContractInstance = pintuContract.at(
        process.env.CONTRACT_ADDRESS
      );

      this.pintuContractInstance = pintuContractInstance;

      try {
        const contractCounter = await this.getCounterValue();
        this.contractCounter = contractCounter;
      } catch (err) {
        this.errContractCounter = `Failed to fetch counter value from the contract`;
      }

      try {
        const accountBalance = await this.getAccountBalance();
        this.accountBalance = window.web3.fromWei(accountBalance, "ether");
      } catch (err) {
        this.errAccountBalance = `Failed to fetch the deposits balance from the contract`;
      }
    }
  },
  data: () => ({
    metamaskIsConnected: false,
    connectedAccount: "",
    loading: false,
    loadingCounter: false,
    loadingWithdrawal: false,
    contractAddress: process.env.CONTRACT_ADDRESS,
    contractNetwork: process.env.ETHEREUM_NETWORK,

    //
    contractCounter: null,
    errContractCounter: null,

    //
    accountBalance: null,
    errAccountBalance: null,

    urlExplorer: process.env.URL_EXPLORER,

    // Counter Increment
    txCounterIncrement: null,

    // DEPOSIT
    depositAmount: 1,
    depositAmountRules: [
      v => !!v || "Deposit Amount is required",
      v => v >= 1 || "Deposit amount minimum 1 ether"
    ],
    txDeposit: null,

    // WITHDRAWAL
    withdrawalAmount: 1,
    withdrawalAmountRules: [
      x => !!x || "Withdrawal Amount is required",
      x => x >= 1 || "Withdrawal amount minimum 1 ether"
    ],
    txWithdrawal: null
  }),

  methods: {
    async getCounterValue() {
      return new Promise((resolve, reject) => {
        this.pintuContractInstance.getCounter((error, data) => {
          if (error) return reject(error);
          return resolve(data.toNumber());
        });
      });
    },

    async getAccountBalance() {
      return new Promise((resolve, reject) => {
        this.pintuContractInstance.balanceOf(
          window.web3.eth.accounts[0],
          (error, data) => {
            if (error) return reject(error);
            return resolve(data);
          }
        );
      });
    },

    async incrementCounter() {
      return new Promise((resolve, reject) => {
        this.pintuContractInstance.incrementCounter((error, data) => {
          if (error) return reject(error);
          this.txCounterIncrement = data;
          return resolve(data);
        });
      });
    },

    async depositToContract(total_amount) {
      return new Promise((resolve, reject) => {
        window.web3.eth.sendTransaction(
          {
            from: window.web3.eth.accounts[0],
            to: process.env.CONTRACT_ADDRESS,
            value: window.web3.toWei(total_amount, "ether")
          },
          (error, data) => {
            if (error) return reject(error);
            console.log(data);
            return resolve(data);
          }
        );
      });
    },

    async withdrawalFromContract(total_amount) {
      return new Promise((resolve, reject) => {
        this.pintuContractInstance.withdraw(
          window.web3.toWei(total_amount, "ether"),
          (error, data) => {
            if (error) return reject(error);
            console.log(data);
            return resolve(data);
          }
        );
      });
    },

    async deposit() {
      this.loading = true;
      if (this.depositAmount < 1) {
        this.loading = false;
        return;
      }
      try {
        const txDeposit = await this.depositToContract(this.depositAmount);
        this.txDeposit = txDeposit;
      } catch (error) {
        console.log(error);
      } finally {
        this.loading = false;
      }
    },

    async withdrawal() {
      this.loadingWithdrawal = true;

      if (this.withdrawalAmount < 1) {
        this.loadingWithdrawal = false;
        return;
      }

      try {
        const txWithdrawal = await this.withdrawalFromContract(
          this.withdrawalAmount
        );
        this.txWithdrawal = txWithdrawal;
      } catch (error) {
        console.log(error);
      } finally {
        this.loadingWithdrawal = false;
      }
    }
  }
};
</script>

<style>
.custom-loader {
  animation: loader 1s infinite;
  display: flex;
}
@-moz-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@-webkit-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@-o-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
