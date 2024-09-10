# Contract Show: World Computer Sculpture Garden

Feel free to reach out for questions either on Discord (0xfff), by email to 0xfff@protonmail or on X/Twitter via [@0xShiroi](https://twitter.com/0xShiroi)

## How to run the test setup
The test setup consist of a local hardhat node + a tiny express server that fetches the html page of the contract page and serves it at localhost:3333

1. Compile contracts, run local node and deploy examples:

```bash
cd contracts
npm i
npx hardhat node
# in a separate window
npx hardhat deploy --network localhost --reset
```

2. Run server to render page from contract:

```bash
cd server
npm i
npx nodemon --watch ../contracts/deployments index.js
# or simply: node index.js
```

You can now visit [localhost:3333](http://localhost:3333) which pulls the HTML directly from the local contract.